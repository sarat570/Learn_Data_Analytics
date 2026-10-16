# StoreOps Secure backend

Private hosted login, server-side store permissions, Cloudflare D1 POS storage, sales dashboards and revision-controlled demand/labor plans. This is the real-data companion to the public synthetic StoreOps demo. No sample stores, users or POS records are seeded into production.

## First use

1. Open https://sarat-storeops-secure.wittyrhino513.chatgpt.site . Sign in with ChatGPT. The site starts owner-private.
2. Click Initialize workspace once. The authenticated first owner becomes its Administrator. Initialization is a one-time, atomic database insert; keep the site owner-private until complete.
3. Create real stores under Store configuration. Default business timezone is Asia/Kolkata. Policies are whole-number values; planning hourly costs are entered in paise.
4. Select a store. Under POS transactions, download the CSV template or enter one line manually. Template examples are not automatically inserted.
5. Add application memberships using actual ChatGPT account emails under User access. Separately grant the intended people access through the private Site hosting controls. Membership alone does not change platform sharing and sends no invitation email. No other users have been added by this delivery.
6. Store members can read/upload only their assigned store; Admin can manage all stores. There is no client-selectable role or demo-account switch in this app.

## Database and transaction contract

D1 is a managed SQLite-compatible operational database. Tables: stores, memberships, pos_lines, store_plans and audit_events. Store/date indexes support daily aggregates. D1 platform limits and retention depend on the hosting plan; do not assume unlimited capacity or free usage. Daily row volume, retention and export/backup policy have not been specified. Monitor growth and benchmark your own workload before expanding. PostgreSQL or an archival pipeline can be evaluated when volume outgrows this design.

POS CSV columns:

```csv
source,transaction_id,line_id,occurred_at,sku,kind,quantity,net_amount
POS,EXAMPLE-001,1,2026-10-16T10:30:00+05:30,SKU-001,sale,2,160.00
```

One row is one item line, not an order total. The selected authorized store is assigned by the server, never trusted from the row. Source/transaction/line IDs must be stable. The natural key is (store_id, source, transaction_id, line_id). Exact normalized replays are skipped. Reusing the same key with different content rejects the entire 20-row batch; no replacement or silent overwrite occurs.

`occurred_at` must include seconds and Z or an explicit timezone offset. The server derives business_date in the store's configured timezone. Timezone changes are rejected once a store has POS rows; changing historical date attribution requires an explicit migration. Net amount is the authoritative POS net line amount in INR, stored as integer paise. Quantity has up to three decimals and is stored in thousandths. Use positive values for both sale and refund; kind determines the stored sign. No taxes, exchange conversions or customer/card identifiers are collected by this schema.

Browser imports support up to 2,000 lines and 1 MB per file, submitted in batches of 20; API requests are limited to 512 KB. Each batch is atomic, but the entire multi-batch file is not: prior successful batches remain committed after a later failure. Correct the rejected row/key and retry; already-inserted identical lines are skipped. Even duplicate-only import attempts conservatively invalidate the store plan.

The UI previews the latest 200 lines and summarizes the latest 90 business dates within the chosen range. All imported lines remain in the database; those display limits are not a retention policy. Full database export, automated backups, daily completeness checks, retention and archival jobs are not implemented in this first version. Keep your source POS exports.

## Real-data planning

After 28 consecutive covered business dates, a four-week same-weekday baseline produces the next seven days of store-level net unit demand and daily labor requirements. Forecasts follow the latest uploaded date, which may be stale. A date with any uploaded rows is treated as covered; the app cannot certify that every POS batch for that date was uploaded. No missing date is automatically filled with zero. Negative net daily quantities are floored at zero for demand forecasting.

A Store manager saves an uplift and reason into a shared Draft snapshot, submits it, Admin approves or returns it, and the Store manager publishes. Every action checks the authenticated membership, assigned store, current status and optimistic revision. POS imports and store policy updates bump a source version, reset existing plans to Draft and clear stale snapshots. Submitting requires a fresh saved snapshot. Publishing does not place orders, approve timecards or disburse payroll.

Purchasing, employee shift allocation, timekeeping and payroll have not yet been migrated from the synthetic demo to this backend. The public demo remains available independently. No browser-local demo configurations or fake user assignments are silently imported into the real database.

## Security boundaries

Hosting dispatch supplies verified identity; the app uses a stable Site-specific user ID and binds allowlisted emails to it on first login. Passwords and OAuth tokens are not stored in this database. All API operations authenticate and authorize server-side; writes also require same-origin JSON requests. Disabling a membership blocks its next request. Application roles and platform sharing are separate gates.

The first-account bootstrap relies on the Site being owner-private. Do not share or make it public before initialization. The deployed Worker should remain behind the platform identity boundary; do not expose the same build on an unprotected direct endpoint that accepts arbitrary identity headers.

Audit rows are server-generated but are not a separately immutable compliance ledger. POS import/configuration writes and their audit rows share a batch. Plan status updates use a conditional revision write followed by a separate audit insert; the plan change may succeed if the later audit write fails. This limitation requires an outbox/transactional audit design before compliance-sensitive use.

## Reproduce and validate

Use the committed pnpm lockfile. The Sites starter handles its build and deployment configuration. No API credentials are included in source.

```sh
node --test tests/*.test.mjs
node node_modules/typescript/bin/tsc --noEmit
```

Eleven tests include real SQLite-backed API tests using the generated migration, plus normalization, CSV, timezone and forecast tests. They cover rejected unauthenticated/cross-store requests, one-time bootstrap, disabled accounts, idempotency, atomic conflict rollback, approval roles, stale plans and POS invalidation. Hosted authentication interaction and browser layout require a signed-in user check; they have not been simulated as production sign-in.

Schema lives in db/schema.ts. Generate new schema-only migrations with the starter's db:generate command; do not edit an applied migration. Database rows must never be committed to GitHub. .openai/hosting.json contains only public binding/identity metadata. Sites publishing applies migrations before deploying the Worker.

References:
- https://developers.cloudflare.com/d1/platform/limits/
- https://developers.cloudflare.com/d1/worker-api/d1-database/
