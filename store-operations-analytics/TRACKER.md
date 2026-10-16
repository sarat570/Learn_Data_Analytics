# Portfolio progress

Use the [GitHub checklist issue](https://github.com/sarat570/Learn_Data_Analytics/issues/1) as the editable source of progress.

Open the [connected UI](https://sarat570.github.io/Learn_Data_Analytics/store-operations-analytics/ui/) to inspect modules, simulate planning changes and keep personal feature statuses/notes. Browser progress is local, with export/import; the GitHub issue is updated manually.

The [Admin and Store walkthrough](MULTI_STORE.md) covers store policies, demo user assignments, store planning, Admin review, publication, activity and built-in dashboards. This local demo cycle is implemented; secure authentication, shared store records and production approval history remain pending.

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

## Secure backend milestone

Hosted sign-in, application memberships, store-level API authorization, D1 POS storage, duplicate-safe imports, sales dashboards and real-data demand/labor plans are implemented in [backend/](backend/README.md). Open the [secure app](https://sarat-storeops-secure.wittyrhino513.chatgpt.site). First owner initialization is pending your sign-in. Migrating purchasing, rosters, timekeeping and pay remains separate work.
