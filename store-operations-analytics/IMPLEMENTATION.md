# Implementation sequence

This prototype follows the six-module source plan. It replaces the earlier separate dashboard-kit direction with one integrated portfolio project.

## Stage 1 — Run and understand the local prototype

Run the demo and tests. Inspect `outputs/run-summary.json`, then join the tables in `operations.sqlite` using any SQLite client. Read `pipeline.py` in workflow order. Change a sample employee availability row or inventory value and rerun without `--demo`; explain how the downstream outputs change. Keep a pristine copy of fixtures before experiments.

## Stage 2 — Assemble three Power BI reports

Follow `powerbi/BUILD.md`. Reconcile cards with the run summary. Build Volume and Purchasing first, then Labor and Timekeeping, then Illustrative Pay. Use native Desktop visuals and real screenshots. The pay report should be labelled illustrative throughout. PBIX files are not included or validated in this package.

## Stage 3 — Snowflake portfolio deployment

Choose your own Snowflake account, warehouse, database and role. Inspect `snowflake/setup.sql` before execution: it contains explicit CREATE OR REPLACE statements for the dedicated portfolio schema tables. Use a dedicated scratch schema. No cloud account or credits were used for this delivery.

Load the typed output tables using the generated file format and PUT/COPY examples, or upload each CSV through your account's supported loading interface. Match file names and headers precisely. Run reporting views and reconcile WAPE, labor gaps and gross pay to the local summary. Connect Power BI to these tables only after this reconciliation. This migrates the reporting data; it does not move the forecasting/scheduling engine into Snowflake.

For automated production refresh, implement raw/staging/mart layers, batch IDs, load timestamps, source hash, validation status and idempotent MERGE keys. Preserve forecast origin/model versions and approval history. Current local outputs are replaceable snapshots rather than an audited event store. Promote forecasting and scheduling code to a scheduled Python job only after reconciling outputs; no scheduled task is created here.

## Stage 4 — Google Sheets and POS ingestion

Your plan leaves POS vendor, authentication, Sheet IDs and column contracts unspecified. Start with the bundled `inputs/` contracts and an authorized CSV export. A live integration needs the chosen POS export/API, the selected Google Sheet and credentials supplied through the platform's secure credential mechanism. Do not put service keys in GitHub.

Timekeeping sheets should contain one row per employee/date for this version. Maintain typed timestamps, explicit timezone, unpaid-break minutes, approval state and approver identity. Keep manual time entry separate from computed approved hours. A production approval action needs authenticated identity, role authorization and an append-only audit trail. A Power BI report displays approval state; it does not implement approval writeback itself.

## Stage 5 — Scheduling and payroll expansion

Add time intervals, roles/skills, break coverage, leave and carry-in weekly hours before calling this a store scheduling tool. A constraint solver may follow the baseline allocator. Validate feasibility and report the reason for every unfilled interval. Historical actual hours are necessary to calibrate productivity, not just assumed units/hour.

For actual payroll, select the country and payroll provider and agree the integration file/API contract. Add employee rate history, payroll-period closure, correction/reversal handling, approval audit and precision rules. Keep the current gross-pay demo separate from any bank or payroll-provider submission. Jurisdiction-specific calculations have not been implemented.

## Completion criteria for the portfolio

1. Demo and six tests pass from a clean checkout.
2. You can explain forecast leakage prevention, MOQ rounding, infeasible schedules and blocked timecards.
3. All three Power BI pages are built, filtered and reconciled.
4. README contains actual report screenshots and distinguishes local work from deployed cloud work.
5. If Snowflake is used, record deployment and reconciliation evidence without credentials.

References: Microsoft Power BI star schema guidance: https://learn.microsoft.com/power-bi/guidance/star-schema . Snowflake local file bulk loading: https://docs.snowflake.com/en/user-guide/data-load-local-file-system .
