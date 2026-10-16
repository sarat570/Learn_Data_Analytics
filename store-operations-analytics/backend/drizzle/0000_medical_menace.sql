CREATE TABLE `audit_events` (
	`id` text PRIMARY KEY NOT NULL,
	`actor_id` text NOT NULL,
	`action` text NOT NULL,
	`store_id` text,
	`detail` text NOT NULL,
	`created_at` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `memberships` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text,
	`email` text NOT NULL,
	`role` text NOT NULL,
	`store_id` text,
	`active` integer DEFAULT 1 NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`store_id`) REFERENCES `stores`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `memberships_email` ON `memberships` (`email`);--> statement-breakpoint
CREATE UNIQUE INDEX `memberships_user` ON `memberships` (`user_id`);--> statement-breakpoint
CREATE TABLE `store_plans` (
	`store_id` text PRIMARY KEY NOT NULL,
	`revision` integer DEFAULT 1 NOT NULL,
	`status` text DEFAULT 'DRAFT' NOT NULL,
	`uplift` integer DEFAULT 0 NOT NULL,
	`note` text DEFAULT '' NOT NULL,
	`snapshot` text NOT NULL,
	`approved_by` text,
	`updated_at` text NOT NULL,
	FOREIGN KEY (`store_id`) REFERENCES `stores`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE TABLE `pos_lines` (
	`id` text PRIMARY KEY NOT NULL,
	`store_id` text NOT NULL,
	`source` text NOT NULL,
	`transaction_id` text NOT NULL,
	`line_id` text NOT NULL,
	`occurred_at` text NOT NULL,
	`business_date` text NOT NULL,
	`sku` text NOT NULL,
	`kind` text NOT NULL,
	`quantity_milli` integer NOT NULL,
	`net_minor` integer NOT NULL,
	`fingerprint` text NOT NULL,
	`created_by` text NOT NULL,
	`created_at` text NOT NULL,
	FOREIGN KEY (`store_id`) REFERENCES `stores`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `pos_natural_key` ON `pos_lines` (`store_id`,`source`,`transaction_id`,`line_id`);--> statement-breakpoint
CREATE INDEX `pos_store_date` ON `pos_lines` (`store_id`,`business_date`);--> statement-breakpoint
CREATE INDEX `pos_date` ON `pos_lines` (`business_date`);--> statement-breakpoint
CREATE TABLE `stores` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`timezone` text DEFAULT 'Asia/Kolkata' NOT NULL,
	`units_per_hour` integer DEFAULT 30 NOT NULL,
	`fixed_hours` integer DEFAULT 4 NOT NULL,
	`min_staff` integer DEFAULT 2 NOT NULL,
	`hourly_cost_minor` integer DEFAULT 18000 NOT NULL,
	`data_version` integer DEFAULT 1 NOT NULL,
	`active` integer DEFAULT 1 NOT NULL,
	`created_at` text NOT NULL
);
