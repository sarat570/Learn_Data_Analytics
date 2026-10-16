# Commercial plan alignment

Selected delivery path: upgrade the existing D1 pilot first; PostgreSQL remains a commercial release gate. This update implements the restaurant operational core and makes incomplete scope visible in the app's release-gates view.

| Plan capability | Pilot delivery | Remaining gate |
|---|---|---|
| Tenant / outlet model | Isolated organizations, 1–10 outlets, scoped APIs and database references | Multi-organization accounts, commercial provisioning |
| Access | Admin, assigned store manager, assigned kitchen role | Area-manager and employee roles; full permissions matrix review |
| POS ingestion | CSV, normalization, idempotent keys, invalid-row quarantine, source reconciliation | Scheduled connectors, raw-file archive, pipeline alerts, automated completeness |
| Demand | 56 covered-day readiness, daily same-weekday baseline, freshness visibility | 8–12-week pilot assessment, backtesting, uncertainty, interval forecast, promotions |
| Recipes | Effective-dated versions, yield, explicit base units, station workload metadata | Unit-conversion catalog, richer allergens/BOM maintenance |
| Preparation | Manual cold start, forecast suggestions, capacity cap, approval, immutable snapshots and stale-source review | Partial batches, rolling interval production, waste-risk optimization |
| Inventory | Expiry batches, FEFO, ledger, receipts, count variance, prepared serving | Purchasing/vendor orders, transfers, refund returns, automated POS serving |
| Waste | Reason codes, batch/unit quantities, known/unknown costs, cost/net ratio | Verified logging coverage, baseline/intervention evidence and savings attribution |
| Workforce | Existing daily demand-to-labor estimate | Interval skills/availability optimizer and compliant rosters |
| Time and pay | Explicitly deferred | Timecards, exceptions, approvals, payroll integrations |
| Actions | Owned priority/due/source queue, closure reasons | Automated opportunity detection and outcome attribution |
| Dashboards | Command centre, sales/SKU mix, waste, prep, expiry/current stock, tasks, readiness | Full 16-dashboard suite; labor, attendance, verified ROI and executive comparisons |
| Commercial platform | Pilot outlet entitlement; private identity boundary | Billing, subscriptions, PostgreSQL, support tools and onboarding automation |
| Reliability | Atomic stock transactions, retry keys, revision guards, API/SQL tests | Load/concurrency benchmark, backup/restore drill, monitoring, alerting, incident runbooks |
| Privacy / security | Tenant scoping and kitchen financial redaction | Formal review, retention/export/deletion controls, immutable audit/outbox |
| Pilot success | Honest readiness and missing-cost states; no fabricated savings | Real restaurant baseline, intervention, adoption and independently checked outcomes |

## Acceptance example

120 portions × 0.08 kg net ingredient ÷ 0.80 usable yield = 12 kg issued. Production consumes ingredient batches once; subsequent prepared-serving entries reduce prepared inventory only. Tests cover this formula and the receive → FEFO production → served → waste → physical-count ledger flow.

## Deployment boundaries

No real source records are seeded or copied from the synthetic public portfolio demo. Existing legacy single-estate records can be assigned to their original administrator's organization through the explicit upgrade action. Applied migrations must remain immutable. The 50,000 POS lines/day scenario in the plan is a capacity target, not a measured result.
