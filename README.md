# Sarat Akella — Data Analytics Workspace

Retail, workforce and business intelligence portfolio work, with a learning tracker and a connected store-operations project.

| Workspace | Open it | Status |
|---|---|---|
| Connected operations UI | [Launch StoreOps](https://sarat570.github.io/Learn_Data_Analytics/store-operations-analytics/ui/) | Module views, scenario simulator, data explorer and personal feature tracker |
| Store operations project | [Source and instructions](store-operations-analytics/README.md) | Six-module local prototype; synthetic demo data |
| Shared project progress | [Implementation checklist](https://github.com/sarat570/Learn_Data_Analytics/issues/1) | Track report assembly and remaining integrations |
| Learning tracker | [Open learning workspace](https://sarat570.github.io/Learn_Data_Analytics/) | Existing preparation tracker |

The operations UI is a static demo of connected planning calculations. Power BI Desktop report assembly, Snowflake deployment, live ingestion and authenticated approvals remain separate implementation milestones. UI feature status saves locally in your browser and can be exported/imported; it does not update the shared GitHub checklist.

## Run the operations pipeline

```sh
cd store-operations-analytics
python3 pipeline.py --demo
python3 -m unittest -v
python3 build_ui.py
node --test ui/core.test.mjs
```

`--demo` regenerates synthetic fixtures. See the project README before using your own inputs.
