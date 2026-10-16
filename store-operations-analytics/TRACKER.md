# Portfolio progress

Use the [GitHub checklist issue](https://github.com/sarat570/Learn_Data_Analytics/issues/1) as the editable source of progress.

Open the [connected UI](https://sarat570.github.io/Learn_Data_Analytics/store-operations-analytics/ui/) to inspect modules, simulate planning changes and keep personal feature statuses/notes. Browser progress is local, with export/import; the GitHub issue is updated manually.

| Stage | Status | Evidence or next action |
|---|---|---|
| Local six-module pipeline | Complete | `pipeline.py`, synthetic fixtures and generated outputs |
| Automated correctness checks | Complete | Six tests in `test_pipeline.py` passed before publishing |
| Power BI report assembly | Next | Follow `powerbi/BUILD.md`; begin with Volume and Purchasing |
| Report validation and screenshots | Pending | Match totals to `outputs/run-summary.json`; commit PBIX/screenshots |
| Snowflake reporting tables | Pending | Review/load `snowflake/setup.sql` in your own dedicated schema |
| Live POS and Google Sheets ingestion | Pending | Choose source contracts and authorized connections |
| Authenticated manager approvals | Pending | Implement identity, authorization and approval audit history |
| Production scheduling and payroll | Pending | Expand constraints/carry-in hours and define provider integration |

## First local session

From the repository root:

```sh
cd store-operations-analytics
python3 pipeline.py --demo
python3 -m unittest -v
```

Then import `outputs/` CSVs into Power BI Desktop. Check off the local-run task in the issue once both commands succeed on your machine. The tracker is manual; completing work does not automatically update its checkboxes.
