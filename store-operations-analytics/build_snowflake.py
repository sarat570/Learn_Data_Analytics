"""Generate Snowflake snapshot-loading scaffold from local verified exports."""
import sqlite3, re
from pathlib import Path
ROOT=Path(__file__).resolve().parent
db=sqlite3.connect(ROOT/'operations.sqlite')
sql=['-- PORTFOLIO ONLY: select your database, warehouse and a dedicated schema first.',
     '-- This scaffold replaces exported snapshot tables. Review before running.',
     '-- No Snowflake execution or cloud scheduling has been performed.',
     "CREATE FILE FORMAT IF NOT EXISTS portfolio_csv TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='\"' NULL_IF=('') EMPTY_FIELD_AS_NULL=TRUE;",
     'CREATE STAGE IF NOT EXISTS portfolio_stage FILE_FORMAT=portfolio_csv;']
for table, in db.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"):
    assert re.fullmatch('[A-Za-z]+',table)
    defs=[]
    for _,col,kind,*_ in db.execute(f'PRAGMA table_info({table})'):
        dtype='NUMBER(18,4)' if kind=='REAL' else 'VARCHAR'
        if col in ['Date','Origin','AsOfDate','RecommendedOrderDate','ExpectedArrivalDate']:dtype='DATE'
        if col in ['Start','End','ClockIn','ClockOut']:dtype='TIMESTAMP_NTZ'
        defs.append(f'  "{col}" {dtype}')
    sql.extend([f'\nCREATE OR REPLACE TABLE "{table}" (\n'+',\n'.join(defs)+'\n);',
                f'-- In an authenticated CLI, replace /ABSOLUTE/PATH with the local extracted project path:',
                f'-- PUT file:///ABSOLUTE/PATH/outputs/{table}.csv @portfolio_stage/{table}/ AUTO_COMPRESS=TRUE OVERWRITE=TRUE;',
                f'-- After staging, load this snapshot once (recreate table before loading a replacement snapshot):',
                f'COPY INTO "{table}" FROM @portfolio_stage/{table}/ FILE_FORMAT=(FORMAT_NAME=portfolio_csv) ON_ERROR=ABORT_STATEMENT;'])
sql.extend(['''
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
'''])
p=ROOT/'snowflake/setup.sql';p.parent.mkdir(exist_ok=True);p.write_text('\n'.join(sql))
print('Generated Snowflake scaffold; not executed against Snowflake.')
