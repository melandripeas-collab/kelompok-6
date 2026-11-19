ALTER TABLE `user`
    ADD COLUMN `api_token` VARCHAR(64) NULL AFTER `password`,
    ADD UNIQUE KEY `uq_user_api_token` (`api_token`);
