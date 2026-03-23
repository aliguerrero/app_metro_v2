-- Seguridad de login
-- Proyecto: app_metro
-- Base: bdapp_metro

ALTER TABLE `user_system`
  ADD COLUMN IF NOT EXISTS `failed_login_attempts` SMALLINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Intentos fallidos consecutivos de login' AFTER `password`,
  ADD COLUMN IF NOT EXISTS `account_locked` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=cuenta bloqueada por seguridad' AFTER `failed_login_attempts`,
  ADD COLUMN IF NOT EXISTS `locked_at` DATETIME NULL COMMENT 'Fecha/hora de bloqueo de la cuenta' AFTER `account_locked`,
  ADD COLUMN IF NOT EXISTS `password_reset_required` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1=debe recuperar clave para desbloquear' AFTER `locked_at`,
  ADD COLUMN IF NOT EXISTS `last_login_at` DATETIME NULL COMMENT 'Ultimo inicio de sesion exitoso' AFTER `password_reset_required`,
  ADD COLUMN IF NOT EXISTS `last_login_ip` VARCHAR(45) NULL COMMENT 'IP del ultimo inicio de sesion exitoso' AFTER `last_login_at`,
  ADD INDEX IF NOT EXISTS `idx_user_system_login_lock` (`username`, `account_locked`, `password_reset_required`);
