-- PORTFOLIO ONLY: select your database, warehouse and a dedicated schema first.
-- This scaffold replaces exported snapshot tables. Review before running.
-- No Snowflake execution or cloud scheduling has been performed.
CREATE FILE FORMAT IF NOT EXISTS portfolio_csv TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"' NULL_IF=('') EMPTY_FIELD_AS_NULL=TRUE;
CREATE STAGE IF NOT EXISTS portfolio_stage FILE_FORMAT=portfolio_csv;

CREATE OR REPLACE TABLE "DimDate" (
  "Date" DATE,
  "Month" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/DimDate.csv @portfolio_stage/DimDate/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "DimDate" FROM @portfolio_stage/DimDate/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "DimEmployee" (
  "EmployeeID" VARCHAR,
  "StoreID" VARCHAR,
  "Role" VARCHAR,
  "HourlyRate" VARCHAR,
  "MaxWeeklyHours" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/DimEmployee.csv @portfolio_stage/DimEmployee/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "DimEmployee" FROM @portfolio_stage/DimEmployee/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "DimProduct" (
  "ProductID" VARCHAR,
  "Product" VARCHAR,
  "Price" VARCHAR,
  "Cost" VARCHAR,
  "SupplierID" VARCHAR,
  "LeadDays" VARCHAR,
  "MOQ" VARCHAR,
  "PackSize" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/DimProduct.csv @portfolio_stage/DimProduct/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "DimProduct" FROM @portfolio_stage/DimProduct/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "DimStore" (
  "StoreID" VARCHAR,
  "Store" VARCHAR,
  "UnitsPerHour" VARCHAR,
  "FixedHours" VARCHAR,
  "MinStaff" VARCHAR,
  "OpenHours" VARCHAR,
  "HourlyRate" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/DimStore.csv @portfolio_stage/DimStore/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "DimStore" FROM @portfolio_stage/DimStore/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactBacktest" (
  "Date" DATE,
  "StoreID" NUMBER(18,4),
  "ProductID" NUMBER(18,4),
  "ForecastUnits" NUMBER(18,4),
  "Origin" DATE,
  "Model" VARCHAR,
  "ActualUnits" NUMBER(18,4),
  "ActualSales" NUMBER(18,4),
  "AbsoluteError" NUMBER(18,4),
  "SquaredError" NUMBER(18,4),
  "BaselineUnits" NUMBER(18,4),
  "BaselineAbsoluteError" NUMBER(18,4),
  "BiasUnits" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactBacktest.csv @portfolio_stage/FactBacktest/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactBacktest" FROM @portfolio_stage/FactBacktest/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactCoverage" (
  "Date" DATE,
  "StoreID" NUMBER(18,4),
  "RequiredHours" NUMBER(18,4),
  "ScheduledHours" NUMBER(18,4),
  "UnfilledHours" NUMBER(18,4),
  "ExcessHours" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactCoverage.csv @portfolio_stage/FactCoverage/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactCoverage" FROM @portfolio_stage/FactCoverage/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactForecast" (
  "Date" DATE,
  "StoreID" NUMBER(18,4),
  "ProductID" NUMBER(18,4),
  "ForecastUnits" NUMBER(18,4),
  "Origin" DATE,
  "Model" VARCHAR,
  "ForecastSales" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactForecast.csv @portfolio_stage/FactForecast/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactForecast" FROM @portfolio_stage/FactForecast/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactLaborForecast" (
  "Date" DATE,
  "StoreID" NUMBER(18,4),
  "ForecastUnits" NUMBER(18,4),
  "VariableHours" NUMBER(18,4),
  "FixedHours" NUMBER(18,4),
  "RequiredHours" NUMBER(18,4),
  "ForecastLaborCost" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactLaborForecast.csv @portfolio_stage/FactLaborForecast/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactLaborForecast" FROM @portfolio_stage/FactLaborForecast/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactPay" (
  "Date" DATE,
  "EmployeeID" VARCHAR,
  "StoreID" NUMBER(18,4),
  "RegularHours" NUMBER(18,4),
  "OvertimeHours" NUMBER(18,4),
  "RegularPay" NUMBER(18,4),
  "OvertimePay" NUMBER(18,4),
  "IllustrativeGrossPay" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactPay.csv @portfolio_stage/FactPay/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactPay" FROM @portfolio_stage/FactPay/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactPurchasing" (
  "AsOfDate" DATE,
  "StoreID" NUMBER(18,4),
  "ProductID" NUMBER(18,4),
  "SupplierID" VARCHAR,
  "OnHand" NUMBER(18,4),
  "InventoryPosition" NUMBER(18,4),
  "DailyDemand" NUMBER(18,4),
  "ReorderPoint" NUMBER(18,4),
  "TargetStock" NUMBER(18,4),
  "OrderUnits" NUMBER(18,4),
  "OrderCost" NUMBER(18,4),
  "RecommendedOrderDate" DATE,
  "ExpectedArrivalDate" DATE,
  "StockoutBeforeArrival" NUMBER(18,4)
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactPurchasing.csv @portfolio_stage/FactPurchasing/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactPurchasing" FROM @portfolio_stage/FactPurchasing/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactSchedule" (
  "Date" DATE,
  "StoreID" NUMBER(18,4),
  "EmployeeID" VARCHAR,
  "Role" VARCHAR,
  "Start" TIMESTAMP_NTZ,
  "End" TIMESTAMP_NTZ,
  "ScheduledPaidHours" NUMBER(18,4),
  "Status" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactSchedule.csv @portfolio_stage/FactSchedule/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactSchedule" FROM @portfolio_stage/FactSchedule/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE TABLE "FactTimekeeping" (
  "Date" DATE,
  "EmployeeID" VARCHAR,
  "ClockIn" TIMESTAMP_NTZ,
  "ClockOut" TIMESTAMP_NTZ,
  "UnpaidBreakMinutes" VARCHAR,
  "ApprovalStatus" VARCHAR,
  "ApprovedBy" VARCHAR,
  "StoreID" NUMBER(18,4),
  "PaidHours" NUMBER(18,4),
  "EligibleForPay" NUMBER(18,4),
  "Exceptions" VARCHAR
);
-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:
-- PUT file:///ABSOLUTE/PATH/outputs/FactTimekeeping.csv @portfolio_stage/FactTimekeeping/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;
-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):
COPY INTO "FactTimekeeping" FROM @portfolio_stage/FactTimekeeping/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;

CREATE OR REPLACE VIEW "ForecastEvaluation" AS
SELECT "StoreID", SUM("AbsoluteError")/NULLIF(SUM("ActualUnits"),0) AS "WAPE",
 SUM("BaselineAbsoluteError")/NULLIF(SUM("ActualUnits"),0) AS "BaselineWAPE"
FROM "FactBacktest" GROUP BY "StoreID";
CREATE OR REPLACE VIEW "LaborGaps" AS
SELECT "StoreID", SUM("UnfilledHours") AS "UnfilledHours"
FROM "FactCoverage" GROUP BY "StoreID";
CREATE OR REPLACE VIEW "IllustrativePaySummary" AS
SELECT "StoreID", SUM("IllustrativeGrossPay") AS "IllustrativeGrossPay"
FROM "FactPay" GROUP BY "StoreID";
-- Reconcile these views against outputs/run-summary.json before using Power BI.
