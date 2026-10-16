# StoreOps Restaurant Pilot

Restaurant operations for organizations with 1–10 outlets: POS demand, versioned preparation, recipe yield, FEFO ingredient stock, waste and owned actions. Secure live app: https://sarat-storeops-secure.wittyrhino513.chatgpt.site

## First use

1. Sign in with ChatGPT, initialize your organization (or upgrade a legacy workspace).
2. Add outlets, timezone and business-day cutoff under configuration. These date settings lock after POS imports.
3. Add real member emails as admin, store manager or kitchen staff. Hosting sharing is a separate gate; memberships send no invitations. The Site remains owner-private.
4. Add menu SKUs and ingredients using explicit kg, l or each units; create effective-dated recipes with usable yield.
5. Receive ingredient batches with expiry and actual unit costs. Import POS CSV; reconcile daily source line count and signed INR net against the source export.
6. Create a reasoned preparation sheet, approve it, then record production. FEFO issues ingredients exactly once. Record portions served against prepared batches; POS imports do not automatically deplete stock.
7. Log waste, count physical stock, assign actions and close them with evidence.

No synthetic records are seeded. The public GitHub Pages demonstration remains separate from authenticated operational data.

## Data and access

D1 is the lightweight SQLite-compatible pilot database. Server queries and composite database references enforce tenant/outlet scope. One organization membership per account is supported. Admin configures its organization, store managers operate their assigned outlet, kitchen staff see operational views with financial values omitted server-side. Login uses platform-verified identity; no passwords or OAuth tokens are stored.

POS columns: `source,transaction_id,line_id,occurred_at,sku,kind,quantity,net_amount`. A row is an item line; stable source/transaction/line IDs are required. Amount is INR net, stored as integer paise; quantity has up to three decimals. Positive sale/refund inputs are signed according to kind. Timestamps require seconds and an explicit timezone offset. Business dates respect the outlet timezone and cutoff.

Browser files are limited to 2,000 rows/1 MB, with validation before writes and 20-row atomic batches. Invalid rows are retained in a scoped quarantine; an invalid batch posts no POS lines. Exact duplicate imports are skipped; conflicting keys reject the batch. A multi-batch file is not one transaction: earlier successful batches remain if a later conflict occurs. Keep original exports. Quarantine resolution retains the row and a reason; it does not import a correction automatically.

## Planning and inventory contract

Automatic demand requires 56 consecutive covered business dates; the baseline uses four previous same weekdays. A covered day does not prove source completeness. Open quarantine blocks recommendations. Daily source reconciliation is a manual control, not an automated completeness guarantee. Cold-start preparation uses an explicit manual reason.

Recipes use portions × net ingredient quantity ÷ usable yield, with fixed-point quantities. Stock is never summed across unlike units. FEFO excludes expired batches from production and serving. Inventory issues, receipts, waste and counts are transactional ledger entries with balance guards and idempotency keys. Unknown costs remain unknown. Stock counts are distinct from waste.

Preparation carries a recipe/source snapshot and revision. Changed POS, policy or recipe flags review; approved snapshots are not silently rewritten. Published demand snapshots are immutable. Production is limited to the current business date and available unexpired stock; partial production is not implemented. Prepared serving is an explicit entry and must not be duplicated through another inventory integration.

Stock pages show current balances even when a historical business date is selected. Waste percentages use recorded known ingredient costs/net sales, not verified savings. Missing costs and zero denominators are explicit. Refund-related physical stock returns require manual review.

## Commercial limits

This is a pilot implementation aligned to the supplied WFM Commercial Project Plan, not a completed commercial WFM product. See [COMMERCIAL_ALIGNMENT.md](COMMERCIAL_ALIGNMENT.md) for scope and release gates. No 50,000-lines/day capacity benchmark, automated feed, billing, raw-file archive, restore exercise, interval forecasting, roster optimizer, employee timecards or payroll integration is claimed.

Audit events are useful operational history, not an immutable compliance ledger. Some demand-plan audit/snapshot writes follow the plan transition separately; a transactional outbox is required before compliance-sensitive use. PostgreSQL migration, capacity tests, privacy/retention/backup controls and support operations remain release gates.

## Validate and deploy

Use the committed pnpm lockfile and Sites build workflow.

```sh
node --test tests/*.test.mjs
node node_modules/typescript/bin/tsc --noEmit
```

The tests run actual route handlers against SQLite with all schema migrations and mocked verified identity. They cover access boundaries, POS atomicity/quarantine, planning revisions, immutable publication, recipe yield, FEFO stock flows, retry safety, expired stock and kitchen financial redaction. Production login interaction and responsive browser layout still require a signed-in manual check.

Schema: `db/schema.ts`; migrations: `drizzle/`. Never edit an applied migration or commit customer records. Native publishing applies schema migrations before deploying the Worker.
