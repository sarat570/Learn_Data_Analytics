CREATE TABLE `pos_quarantine` (
	`id` text PRIMARY KEY NOT NULL,
	`tenant_id` text NOT NULL,
	`store_id` text NOT NULL,
	`fingerprint` text NOT NULL,
	`payload_json` text NOT NULL,
	`error` text NOT NULL,
	`status` text DEFAULT 'OPEN' NOT NULL,
	`resolution` text,
	`created_at` text NOT NULL,
	FOREIGN KEY (`tenant_id`,`store_id`) REFERENCES `stores`(`tenant_id`,`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `quarantine_payload` ON `pos_quarantine` (`tenant_id`,`store_id`,`fingerprint`);--> statement-breakpoint
CREATE UNIQUE INDEX `task_open_source` ON `tasks` (`tenant_id`,`store_id`,`source`) WHERE "tasks"."status"='OPEN' AND "tasks"."source"!='manual' AND "tasks"."source"!='';--> statement-breakpoint
CREATE TRIGGER stock_expiry_guard BEFORE INSERT ON stock_movements WHEN NEW.kind IN ('ingredient_issue','served') BEGIN SELECT CASE WHEN (SELECT expires_at FROM stock_batches WHERE id=NEW.batch_id)<=NEW.created_at THEN RAISE(ABORT,'expired_stock_blocked') END; END;
