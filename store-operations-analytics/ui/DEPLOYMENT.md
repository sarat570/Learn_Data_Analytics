# Crewmise on GitHub Pages

Public entry point: https://sarat570.github.io/Learn_Data_Analytics/store-operations-analytics/ui/

This build is independent of the former hosted Site. It contains no link to that host and no hosted identity integration. It runs as static HTML, CSS and JavaScript on GitHub Pages.

## Preview both workflows

Use **Preview as** in the header to select **Admin · all stores** or a **Store user**. Store views are scoped to their assigned location; **Return to Admin** exits that view. Both perspectives share the same browser workspace, so a store submission appears in Admin plan approvals. Admin approves, then the store publishes. Configuration changes invalidate the corresponding approval.

The owner is the sole Admin profile. New profiles and imported backups cannot introduce another Admin. These are synthetic demo profiles, not authenticated users or a security boundary. Browser data can be edited by the visitor.

## Storage and existing backend

Changes save in localStorage in this browser. Export a workspace backup before changing devices. No real employee or POS data should be placed in this public demo.

GitHub Pages cannot run the existing server, SQLite/D1 database or secure sign-in. Existing secure restaurant/workforce features and records remain in the prior private backend; this static build does not migrate or synchronize them. A full migration requires an independently hosted API/database, independent authentication and server-enforced owner-only, outlet-scoped access. An owner troubleshooting session should be read-only by default, time-limited, visibly labelled, and audited by the backend. Never implement production impersonation by changing a client-side role.

No new deployment was made to the former Site. Its existing deployment has not been unpublished: the available hosting tools do not expose an unpublish operation. Disable it through its hosting controls after exporting data and migrating identity/storage.

## Verification

Run `node --test *.test.mjs` in this directory. Deploy these buildless assets through the repository’s existing Pages pipeline. No secrets or identity configuration are required for this synthetic demo.
