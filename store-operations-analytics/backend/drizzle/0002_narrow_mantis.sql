CREATE TABLE `pos_reconciliations` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`business_date` text NOT NULL,
	`expected_lines` integer NOT NULL,
	`expected_net_minor` integer NOT NULL,
	`actual_lines` integer NOT NULL,
	`actual_net_minor` integer NOT NULL,
	`status` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `reconcile_store_date` ON `pos_reconciliations` (`tenant_id`,`store_id`,`business_date`);--> statement-breakpoint
ALTER TABLE `waste_events` ADD `business_date` text DEFAULT '' NOT NULL;--> statement-breakpoint
CREATE TRIGGER membership_scope_insert BEFORE INSERT ON memberships WHEN NEW.tenant_id IS NOT NULL AND NEW.store_id IS NOT NULL BEGIN SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'membership_tenant_scope') END; END;
--> statement-breakpoint
CREATE TRIGGER membership_scope_update BEFORE UPDATE ON memberships WHEN NEW.tenant_id IS NOT NULL AND NEW.store_id IS NOT NULL BEGIN SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'membership_tenant_scope') END; END;
--> statement-breakpoint
CREATE TRIGGER pos_scope_update BEFORE UPDATE ON pos_lines WHEN NEW.tenant_id IS NOT NULL BEGIN SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'pos_tenant_scope') END; END;
--> statement-breakpoint
CREATE TRIGGER plan_scope_insert BEFORE INSERT ON store_plans WHEN NEW.tenant_id IS NOT NULL BEGIN SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'plan_tenant_scope') END; END;
--> statement-breakpoint
CREATE TRIGGER plan_scope_update BEFORE UPDATE ON store_plans WHEN NEW.tenant_id IS NOT NULL BEGIN SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'plan_tenant_scope') END; END;
--> statement-breakpoint
CREATE TRIGGER pilot_store_limit BEFORE INSERT ON stores WHEN NEW.tenant_id IS NOT NULL BEGIN SELECT CASE WHEN (SELECT COUNT(*) FROM stores WHERE tenant_id=NEW.tenant_id AND active=1)>=(SELECT max_outlets FROM tenants WHERE id=NEW.tenant_id) THEN RAISE(ABORT,'pilot_outlet_limit') END; END;
