# Build the Power BI report

Status: assembly guide and measures supplied; no PBIX has been created or tested in Power BI Desktop.

## Import and model

Use Get data → Text/CSV for every CSV under `outputs/`, keeping the filenames as table names. Import `inputs/sales.csv` as `FactSalesHistory` only if you want a separate historical sales page; it is not required for the three pages below. `run-summary.json` is a reconciliation file, not a report table.

In Power Query, set Date, Origin, AsOfDate, RecommendedOrderDate and ExpectedArrivalDate to Date. Set Start, End, ClockIn and ClockOut to Date/Time, replacing invalid strings with null through an explicit error-handling step; do not discard the associated timekeeping exception rows. Set counts and numeric IDs to Whole number; hours, units forecasts, money and errors to Decimal number. EmployeeID and SupplierID are Text. ApprovalStatus, ApprovedBy, Exceptions, Role, Model and Status are Text. EligibleForPay and StockoutBeforeArrival are Whole number flags.

Use active, single-direction one-to-many relationships:

| Dimension key | Fact foreign keys |
|---|---|
| DimDate[Date] | Date in FactForecast, FactBacktest, FactLaborForecast, FactSchedule, FactCoverage, FactTimekeeping and FactPay; AsOfDate in FactPurchasing |
| DimStore[StoreID] | StoreID in every fact table |
| DimProduct[ProductID] | ProductID in FactForecast, FactBacktest and FactPurchasing |
| DimEmployee[EmployeeID] | EmployeeID in FactSchedule, FactTimekeeping and FactPay |

Do not connect dimensions to each other or facts to other facts. DimEmployee contains StoreID as an attribute, but do not relate it to DimStore. Unknown employee timecards have StoreID -1 and appear in the blank/unknown dimension group; do not hide them from exception reporting. Mark DimDate as the date table and use its dates in axes and slicers. Avoid connecting DimDate to both Origin and Date as active relationships.

Import `theme.json`. Canvas 1280 × 720, 16px margins/gaps, 32px page title, 12px labels, 26px KPI values. Use white panels on a light background. Add the footer `Synthetic portfolio data | Forecast origin 1 Jan 2026 | Illustrative planning rules` on every page.

Add each expression from `measures.dax` separately. Currency is INR. Format rates as 0.0%, hours as 0.0, currency as ₹#,0, and counts as whole numbers. Keep output column names unchanged. DAX is provided for Desktop validation and has not been executed here.

## Page 1 — Volume and purchasing

Use a City/Store slicer that controls both sections. Keep product filtering scoped to this page. The backtest period and future plan are different date ranges; do not use one global date filter that makes half the page blank. Label each section with its dates, and leave date interaction disabled between the historical and future sections.

Top cards: WAPE %, Baseline WAPE %, Purchase Recommendation Cost, Products at Arrival Risk. Rename the final card `Store-product arrival risks`, because it counts store/product combinations rather than distinct products.

Upper left: line chart with FactBacktest[Date] on X and Holdout Actual Units / Holdout Forecast Units on Y; period 4–31 December 2025. Upper right: inventory table with Store, Product, OnHand, ReorderPoint, OrderUnits, SupplierID, ExpectedArrivalDate and StockoutBeforeArrival from FactPurchasing. Include both Store and Product in its grain; stock is a snapshot on 31 December, not additive over time. Use red conditional formatting for arrival-risk flag 1.

Lower panel: future forecast chart using FactForecast[Date], Forecast Units, Product legend; period 1–7 January 2026. Purchasing recommendations are point-in-time decisions, not a historical spending trend. OrderCost is recommended spend, not placed or paid orders. Product filters must not be allowed to imply a recomputed product-specific labor model.

## Page 2 — Labor and timekeeping

Remove/suppress product slicers because labor is at store/day grain. Slicers: DimStore[Store], DimDate[Date] restricted to 1–7 January 2026. Cards: Required Hours, Scheduled Hours, Unfilled Hours, Blocked Timecards. Clustered column chart (not stacked): scheduled and approved eligible hours by store. Stacking these would imply an additive total that is meaningless.

Second chart: required versus scheduled hours by date. Bottom table: FactTimekeeping Date, EmployeeID, StoreID, ApprovalStatus, EligibleForPay, PaidHours and Exceptions; filter EligibleForPay=0. Set row-level PaidHours to Do not summarize. Pair this with a schedule table showing Status=DRAFT. Display `No manager approval interface implemented` next to the schedule table.

Add Forecast Labor to Sales % as a planning card with its formula in a tooltip. It uses required labor cost and forecast sales at store/day grain, not actual labor cost divided by actual sales. Timekeeping demo hours and draft schedules are separately simulated; their difference does not represent a real store performance result.

## Page 3 — Illustrative pay

Slicers: store, date, employee. Cards: Illustrative Gross Pay, Regular Pay, Overtime Pay and Overtime Hours. Column chart: Illustrative Gross Pay by Store. Table: EmployeeID, RegularHours, OvertimeHours, RegularPay, OvertimePay and IllustrativeGrossPay from FactPay. Optional line chart by day; do not present a 12-month payroll trend from seven days of data. Demo overtime may be zero; do not fabricate a trend or hidden overtime to make a chart interesting.

Place visible text: `Gross-pay simulation only. No tax, benefits, deductions, net-pay calculation or disbursement.` Do not label gross pay “total employer cost” because employer taxes/benefits are absent.

## Acceptance checks

1. Clear slicers. WAPE should be 6.62%, baseline WAPE 7.89%, Unfilled Hours 5.4, Blocked Timecards 11 and Illustrative Gross Pay ₹93,840.
2. Filter a store; totals must reconcile with the corresponding CSV records. Check at least one product forecast and one employee pay record manually.
3. Clear the filters; original totals return. Product filters must not change labor/pay visuals, which do not have product grain.
4. Timecard exceptions remain visible even with missing ClockOut. All occurrences of duplicate timecard keys are excluded from pay.
5. Inspect every relationship for unwanted Both directions or automatic fact-to-fact links.
6. Save `store-operations.pbix` and three actual screenshots to a `screenshots/` directory. Add the screenshots to the repository README. Record a short walkthrough explaining metrics, filters and limitations.

References: https://learn.microsoft.com/power-bi/guidance/star-schema and https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-measures .
