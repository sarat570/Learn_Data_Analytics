CREATE TABLE `stock_batches` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`item_id` text NOT NULL,
	`label` text NOT NULL,
	`expires_at` text NOT NULL,
	`unit_cost_minor` integer,
	`balance_micro` integer DEFAULT 0 NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tenant_id`,`item_id`) REFERENCES `items`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `batch_tenant_store_id` ON `stock_batches` (`tenant_id`,`store_id`,`id`);--> statement-breakpoint
CREATE INDEX `batch_fefo` ON `stock_batches` (`tenant_id`,`store_id`,`item_id`,`expires_at`);--> statement-breakpoint
CREATE TABLE `stock_counts` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`batch_id` text NOT NULL,
	`expected_micro` integer NOT NULL,
	`physical_micro` integer NOT NULL,
	`variance_micro` integer NOT NULL,
	`reason` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`,`batch_id`) REFERENCES `stock_batches`(`tenant_id`,`store_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `items` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`sku` text NOT NULL,
	`name` text NOT NULL,
	`kind` text NOT NULL,
	`base_unit` text NOT NULL,
	`default_cost_minor` integer,
	`shelf_hours` integer,
	`capacity_portions` integer,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `items_tenant_sku` ON `items` (`tenant_id`,`sku`);--> statement-breakpoint
CREATE UNIQUE INDEX `items_tenant_id` ON `items` (`tenant_id`,`id`);--> statement-breakpoint
CREATE TABLE `stock_movements` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`batch_id` text NOT NULL,
	`kind` text NOT NULL,
	`quantity_micro` integer NOT NULL,
	`expected_balance_micro` integer,
	`reference` text NOT NULL,
	`created_by` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`,`batch_id`) REFERENCES `stock_batches`(`tenant_id`,`store_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `movement_store_date` ON `stock_movements` (`tenant_id`,`store_id`,`created_at`);--> statement-breakpoint
CREATE TABLE `operation_requests` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`request_key` text NOT NULL,
	`fingerprint` text NOT NULL,
	`response_json` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `operation_request_key` ON `operation_requests` (`tenant_id`,`request_key`);--> statement-breakpoint
CREATE TABLE `prep_plans` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`menu_item_id` text NOT NULL,
	`recipe_id` text NOT NULL,
	`business_date` text NOT NULL,
	`portions` integer NOT NULL,
	`source_data_version` integer NOT NULL,
	`source_forecast_revision` text,
	`snapshot` text NOT NULL,
	`status` text DEFAULT 'DRAFT' NOT NULL,
	`needs_review` integer DEFAULT 0 NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL,
	`author_id` text NOT NULL,
	`approved_by` text,
	`approved_at` text,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tenant_id`,`menu_item_id`) REFERENCES `items`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tenant_id`,`recipe_id`) REFERENCES `recipe_versions`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `prep_tenant_store` ON `prep_plans` (`tenant_id`,`store_id`,`business_date`);--> statement-breakpoint
CREATE TABLE `published_plans` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`revision` integer NOT NULL,
	`snapshot` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `recipe_lines` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`recipe_id` text NOT NULL,
	`ingredient_id` text NOT NULL,
	`net_quantity_micro` integer NOT NULL,
	`yield_basis_points` integer NOT NULL,
	FOREIGN KEY (`tenant_id`,`recipe_id`) REFERENCES `recipe_versions`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tenant_id`,`ingredient_id`) REFERENCES `items`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `recipe_versions` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`menu_item_id` text NOT NULL,
	`version` integer NOT NULL,
	`effective_date` text NOT NULL,
	`station` text NOT NULL,
	`seconds_per_portion` integer NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`menu_item_id`) REFERENCES `items`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `recipe_tenant_id` ON `recipe_versions` (`tenant_id`,`id`);--> statement-breakpoint
CREATE UNIQUE INDEX `recipe_menu_version` ON `recipe_versions` (`tenant_id`,`menu_item_id`,`version`);--> statement-breakpoint
CREATE TABLE `tasks` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`title` text NOT NULL,
	`owner_id` text NOT NULL,
	`due_at` text NOT NULL,
	`priority` text NOT NULL,
	`source` text NOT NULL,
	`status` text DEFAULT 'OPEN' NOT NULL,
	`closure_reason` text,
	`revision` integer DEFAULT 1 NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`tenant_id`,`owner_id`) REFERENCES `memberships`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `tenant_migrations` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	FOREIGN KEY (`tenant_id`) REFERENCES `tenants`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `tenants` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`tier` text DEFAULT 'pilot' NOT NULL,
	`max_outlets` integer DEFAULT 10 NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `waste_events` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`batch_id` text NOT NULL,
	`quantity_micro` integer NOT NULL,
	`cost_minor` integer,
	`reason` text NOT NULL,
	`note` text NOT NULL,
	`created_by` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`,`batch_id`) REFERENCES `stock_batches`(`tenant_id`,`store_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `waste_tenant_store_date` ON `waste_events` (`tenant_id`,`store_id`,`created_at`);--> statement-breakpoint
ALTER TABLE `audit_events` ADD `tenant_id` text REFERENCES tenants(id);--> statement-breakpoint
ALTER TABLE `memberships` ADD `tenant_id` text REFERENCES tenants(id);--> statement-breakpoint
CREATE UNIQUE INDEX `memberships_tenant_id` ON `memberships` (`tenant_id`,`id`);--> statement-breakpoint
ALTER TABLE `store_plans` ADD `tenant_id` text REFERENCES tenants(id);--> statement-breakpoint
ALTER TABLE `pos_lines` ADD `tenant_id` text REFERENCES tenants(id);--> statement-breakpoint
CREATE INDEX `pos_tenant_store_date` ON `pos_lines` (`tenant_id`,`store_id`,`business_date`);--> statement-breakpoint
ALTER TABLE `stores` ADD `tenant_id` text REFERENCES tenants(id);--> statement-breakpoint
ALTER TABLE `stores` ADD `cutoff_hour` integer DEFAULT 0 NOT NULL;--> statement-breakpoint
CREATE UNIQUE INDEX `stores_tenant_id` ON `stores` (`tenant_id`,`id`);--> statement-breakpoint
CREATE TRIGGER stock_movement_validate BEFORE INSERT ON stock_movements BEGIN
 SELECT CASE WHEN NEW.quantity_micro = 0 THEN RAISE(ABORT,'zero_stock_movement') END;
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stock_batches WHERE id=NEW.batch_id AND tenant_id=NEW.tenant_id AND store_id=NEW.store_id) THEN RAISE(ABORT,'stock_scope_violation') END;
 SELECT CASE WHEN (SELECT balance_micro FROM stock_batches WHERE id=NEW.batch_id)+NEW.quantity_micro<0 THEN RAISE(ABORT,'insufficient_stock') END;
 SELECT CASE WHEN NEW.expected_balance_micro IS NOT NULL AND (SELECT balance_micro FROM stock_batches WHERE id=NEW.batch_id)!=NEW.expected_balance_micro THEN RAISE(ABORT,'stale_stock_balance') END;
END;
--> statement-breakpoint
CREATE TRIGGER stock_movement_post AFTER INSERT ON stock_movements BEGIN
 UPDATE stock_batches SET balance_micro=balance_micro+NEW.quantity_micro WHERE id=NEW.batch_id AND tenant_id=NEW.tenant_id AND store_id=NEW.store_id;
END;
--> statement-breakpoint
CREATE TRIGGER published_plan_no_update BEFORE UPDATE ON published_plans BEGIN SELECT RAISE(ABORT,'published_snapshot_immutable'); END;
--> statement-breakpoint
CREATE TRIGGER published_plan_no_delete BEFORE DELETE ON published_plans BEGIN SELECT RAISE(ABORT,'published_snapshot_immutable'); END;
--> statement-breakpoint
CREATE TRIGGER pos_tenant_scope BEFORE INSERT ON pos_lines WHEN NEW.tenant_id IS NOT NULL BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM stores WHERE id=NEW.store_id AND tenant_id=NEW.tenant_id) THEN RAISE(ABORT,'pos_tenant_scope_violation') END;
END;
