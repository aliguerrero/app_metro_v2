USE `bdapp_metro_audit`;

DROP PROCEDURE IF EXISTS `sp_minute_tasks`$$
CREATE DEFINER=CURRENT_USER PROCEDURE `sp_minute_tasks` ()
BEGIN
  DECLARE v_before BIGINT UNSIGNED DEFAULT 0;
  DECLARE v_after  BIGINT UNSIGNED DEFAULT 0;
  DECLARE v_sync   INT DEFAULT 0;

  SELECT IFNULL(MAX(id_log),0) INTO v_before
  FROM bdapp_metro_audit.log_user;

  CALL bdapp_metro_audit.sp_sync_log_user();

  SELECT IFNULL(MAX(id_log),0) INTO v_after
  FROM bdapp_metro_audit.log_user;

  SET v_sync = GREATEST(v_after - v_before, 0);

  INSERT INTO bdapp_metro_audit.backup_runs(run_at, synced_rows, backed_rows)
  VALUES (NOW(), v_sync, 0);
END$$

DROP PROCEDURE IF EXISTS `sp_sync_log_user`$$
CREATE DEFINER=CURRENT_USER PROCEDURE `sp_sync_log_user` ()
BEGIN
  DECLARE v_last BIGINT UNSIGNED DEFAULT 0;

  SELECT IFNULL(MAX(id_log),0) INTO v_last
  FROM bdapp_metro_audit.log_user;

  INSERT INTO bdapp_metro_audit.log_user
  (id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
   accion, resp_system, data_old, data_new, data_diff, fecha_hora,
   connection_id, db_user, db_host, changed_cols, std_reg)
  SELECT
   id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
   accion, resp_system, data_old, data_new, data_diff, fecha_hora,
   connection_id, db_user, db_host, changed_cols, std_reg
  FROM bdapp_metro.log_user
  WHERE id_log > v_last;
END$$

DELIMITER ;
