# Store Operations Analytics

An implementation of Sarat Akella's six-module store operations plan, designed as an independent GitHub and Power BI portfolio project. All bundled records and approvals are synthetic; no employer data is used.

**Progress:** [implementation checklist](https://github.com/sarat570/Learn_Data_Analytics/issues/1). **Next task:** run the demo locally, then build the Volume and Purchasing report using [the Power BI guide](powerbi/BUILD.md).

## What works now

| Module | Implemented behavior | Current boundary |
|---|---|---|
| Volume forecast | Trailing four same-weekday mean; 7-day forecast; four rolling weekly holdouts; seasonal-naive benchmark | Daily product/store grain; promotions and annual seasonality not modeled |
| Labor forecast | Units-to-hours conversion, fixed tasks, daily minimum staffing floor, cost projection | Single associate role and 8-hour opening day |
| Purchasing | Lead/review/safety coverage, inventory position, MOQ, case-pack rounding, arrival and stockout flags | One supplier per product; on-order units assumed available for inventory position, not timed |
| Labor schedule | Availability-aware greedy whole-day shifts; ISO-week cap; explicit unfilled/excess hours | Draft output only; not optimized; no approval UI |
| Timekeeping | Independent CSV input; duration, duplicate, employee, approval and schedule-variance checks | One shift per employee/day; one manager-name field, no authenticated approval workflow |
| Pay | Eligible approved hours only; illustrative weekly overtime split; gross pay export | No statutory rules, tax, deductions, benefits, payslip, bank file or disbursement |

## Run the prototype

Requires Python 3.10+; no pip packages, cloud services or credentials needed.

```sh
python pipeline.py --demo
python -m unittest -v
```

`--demo` overwrites all input fixtures, including timecards. Use it only for the portfolio demo. For your own data, first copy the example CSV schemas, replace inputs, then run `python pipeline.py` without the flag. Successful runs regenerate `outputs/` tables and `operations.sqlite`. Do not treat old outputs from a failed run as current results. The SQLite database is a convenient local inspection tool, not Snowflake.

Bundled historical sales cover 2025. Forecast origin is January 1, 2026; future dates are a historical demonstration scenario, not a current operational forecast. Demo timecards cover the forecast week to illustrate the later stages of the workflow. They are generated separately from the draft assignments, which intentionally produces schedule exceptions. `DEMO_MANAGER` is fictional approval data, not an action taken by a real manager.

## Verified demo results

- 63 forecast rows: 7 days × 3 stores × 3 products.
- 252 holdout rows: 28 days × 3 stores × 3 products.
- Forecast WAPE: **6.62%**; seasonal-naive WAPE: **7.89%**.
- MAE: **11.09 units**; RMSE: **13.26 units**.
- Unfilled daily labor requirement: **5.4 hours**.
- Blocked timecards: **11**; eligible pay rows: **61**.
- Illustrative gross pay: **INR93,840.00**.

These are reproducible synthetic-demo results, not measured business improvements. The training window for every holdout origin excludes its target dates. Four-week mean forecasts are not recursively updated with actuals inside a holdout. No claim is made that this simple model is best for real stores.

## Files

- `pipeline.py`: fixture generator and local six-module pipeline.
- `inputs/`: CSV contracts and sample input records.
- `outputs/`: calculated report tables and run summary.
- `operations.sqlite`: generated local SQL database.
- `test_pipeline.py`: six focused correctness tests.
- `powerbi/BUILD.md`, `powerbi/measures.dax`, `powerbi/theme.json`: Power BI report specifications.
- `snowflake/setup.sql`: generated typed export tables, stage-loading examples and reporting views. Not executed against Snowflake.
- `IMPLEMENTATION.md`: remaining integration steps mapped to your plan.

## Important model assumptions

Required daily labor is max(forecast units / 30 + 4 fixed hours, 2 staff × 8 hours). All workers have the Associate role. Eight paid hours are assumed per draft shift with zero unpaid break in the demo; this is a fixture assumption. Daily aggregate staffing floors are not a proof of interval-level coverage. The greedy allocator can leave gaps even when another allocation is feasible. It reports gaps rather than claiming optimality.

Weekly schedule caps and illustrative overtime use ISO calendar weeks with a 40-hour threshold and 1.5 multiplier. Opening weekly balances are assumed zero, including the first partial week. Real implementation needs prior hours, complete pay periods, effective-dated rates, configurable break/holiday rules and signed-off payroll requirements. Values are floating-point demonstration calculations, not payroll-grade decimal accounting. ApprovedBy is not authenticated. The exported gross-pay CSV is for analytics only.

Purchasing uses mean daily forecast over seven days. Lead + review + safety coverage is limited to seven days. Safety stock is a policy days-of-cover assumption. Incoming order arrival timing, outstanding allocations, expiry, stock movements, supplier selection, and order approval are not modeled. A stockout warning can remain even after an order recommendation because supply arrives later.

## GitHub and resume

This project lives in the `store-operations-analytics` folder of `sarat570/Learn_Data_Analytics`. Keep its README, source, synthetic inputs, outputs, tests, Power BI instructions and completed reports together. Generate `operations.sqlite` locally with the pipeline; the binary database is not tracked because it can be reproduced from the source CSVs.

The Power BI PBIX report must still be assembled and checked in Desktop. Add actual report screenshots and `store-operations.pbix` after completing `powerbi/BUILD.md`; GitHub does not render a PBIX as an interactive report. Remove `__pycache__` and do not commit credentials or real employee data.

Resume wording after independently running and explaining the pipeline:

“Built a Python and SQL store-operations prototype linking demand forecasting, labor planning, replenishment, scheduling and timecard validation; evaluated forecasts using rolling holdouts and a seasonal-naive baseline on synthetic data.”

Add Power BI and Snowflake implementation claims only after completing those stages.
