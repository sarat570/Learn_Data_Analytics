# Admin and Store planning workspaces

The live UI now demonstrates a multi-store workforce planning cycle inspired by the workflow Sarat described from UKG WFC. It is an independent portfolio implementation, not an integration with UKG or a claim of feature parity.

## Try the full workflow

1. Open https://sarat570.github.io/Learn_Data_Analytics/store-operations-analytics/ui/ . Use **Demo profile** in the top bar to select **Sarat Administrator**.
2. Open **Admin configuration**. Configure productivity, fixed tasks, minimum staffing, planning labor cost, weekly scheduling cap and labor budget separately for each store. Replenishment config controls product lead times, safety/review coverage, MOQ and pack size. Original sample stores are Pune, Hyderabad and Bengaluru.
3. Optionally add another **demo store**. This explicitly clones a selected original store's synthetic fixtures and creates new demo employee IDs plus a manager profile. It does not ingest real location data. Current cap is 100 demo stores.
4. Select the new store's manager profile. The UI shows that profile's assigned location. Open **Store planning**, review the daily forecast, derived hours, coverage gaps and purchasing recommendation.
5. Save a date-specific demand adjustment with a business reason. Only that store's plan changes; the model rebuilds labor, replenishment, draft shifts, timekeeping eligibility and illustrative pay.
6. Enter a review note, acknowledge remaining staffing gaps if any, and **Submit plan to Admin**. Store managers cannot approve their own plan through the demo command interface.
7. Switch to an Admin profile and open **Plan approvals**. Inspect a submission, then approve the current revision or return it with a reason.
8. Switch back to the assigned manager. **Publish approved revision** becomes available. The roster status becomes Published. Only this store's valid, independently approved demo timecards can now enter illustrative pay.
9. Edit an override or relevant configuration. The affected plan resets to Draft, its revision changes and pay eligibility closes until a new review/publication cycle completes.

All profiles and stages above operate in one browser, with a demo role selector. They are not independent signed-in people collaborating over a server.

## What is linked

| Source or action | Downstream effect |
|---|---|
| Store/day forecast override | Units and sales → required labor + replenishment → draft roster → timecard match → illustrative pay |
| Store productivity/fixed/minimum rules | Required hours and planning cost → schedule allocation and coverage gaps |
| Store weekly schedule cap | Available roster capacity → coverage gaps and matching timecards |
| Product lead/safety/review/MOQ/pack | Replenishment recommendations, order cost and arrival-risk warnings |
| Submission and review | Revision-specific status, Admin review and Store publication |
| Plan publication | Published roster → valid timecard eligibility → illustrative gross pay |
| Configuration/forecast edit | Relevant plan approval becomes stale; affected store returns to Draft |

Planning hourly cost is not the employee pay rate. The existing demo pay calculation still uses employee rates, an illustrative weekly threshold and zero opening weekly balances. No statutory payroll configuration is offered.

The purchase recommendation remains a planning output; publishing the store plan does not place an order. Publishing also does not approve individual timecards: their existing fictional approval fields and validation gates remain independent requirements.

## Built-in dashboards

- Admin estate dashboard compares all configured stores, plan status, required/unfilled hours, labor-to-forecast-sales percentage, store budget, purchasing recommendations and blocked timecards.
- Store dashboard and Store planning show only the assigned location in the demo UI. Daily planned versus required hours and linked module details are available without a separate BI tool.
- December backtest scores remain distinct from January planning projections. Demand adjustments do not alter historical accuracy results.
- Before publishing a store plan, timecards include `schedule_not_published`, and the workspace's illustrative pay is zero for that store. This differs intentionally from the raw Python CSV snapshot, which has no publication lifecycle.
- The Admin-only sandbox is temporary. Review/configuration actions are blocked while an unsaved scenario is active; restore the saved workspace first. The sandbox does not create an approvable revision.

## Persistence and access limits

Configuration, user assignments, overrides, workflow stages and local activity save in browser localStorage under `storeops-workforce-v1`. Admin can export/import a JSON workspace backup. Import replaces that browser's workspace after validation. Feature tracker data uses its separate existing backup. Browser storage can be cleared and is editable by the user.

The GitHub Pages site is public. Anyone can switch demo profiles or inspect all bundled synthetic data. Client-side role checks and scoped rendering demonstrate product behavior; they do not enforce confidentiality or protect real employee information. There are no real accounts, passwords, tenant isolation, shared cloud records, authenticated approvals, tamper-resistant audit history or push notifications.

Changes in this browser do not update Python CSV inputs, the Snowflake scaffold or the GitHub issue automatically. The exported workspace is reproducible configuration against the current sample data, not a migration into a live store system.

## Next stage for real store use

Replace the demo role selector with authenticated sessions and server-enforced permissions. Use a shared transactional database for configuration, assignments, forecast runs, plan revisions, approvals and publication snapshots. Keep Snowflake as the analytics warehouse rather than the interactive approval/writeback layer. Every API must verify the signed-in user's store assignments; never accept client-supplied roles as authority.

| Data entity | Needed production responsibility |
|---|---|
| organizations, stores, users, store_assignments | Tenant boundary and store-scoped authorization |
| effective_dated_store_policies, supplier_policies | Versioned rule sets with author and effective dates |
| forecast_runs, store_day_overrides | Reproducible forecasts and reasoned local adjustments |
| plan_revisions, review_events, publication_snapshots | Revision-specific, concurrent-safe approvals |
| employee_assignments, availability, timecards | Skills, shift constraints and validated actuals |
| audit_events, integration_jobs | Server-generated history, idempotent ingestion and retries |

Publish with a conditional update against the approved revision, so another user's change cannot race the approval. Store the published schedule snapshot separately from a reopened draft. The demo instead closes eligibility on reopening; it does not preserve an operational last-published schedule while a replacement is being drafted.

Production scheduling still needs interval-level coverage, breaks, multiple roles, skills, leave, effective-dated employee rates and weekly carry-in hours. Configure payroll integration only after the country and provider requirements are known.

## Validation

```sh
node --test ui/core.test.mjs ui/workforce.test.mjs ui/portal.test.mjs
```

18 JavaScript tests cover Python-output reconciliation, connected calculations, store isolation in demo commands and dashboards, role guards, stale approval invalidation, new store fixtures, publication/pay gating, backup validation and portal rendering. The six original Python tests remain available with `python3 -m unittest -v`. Visual browser QA is unavailable in this environment; deployment and delivered assets are verified separately.
