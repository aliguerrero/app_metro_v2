USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_area_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_au` AFTER UPDATE ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'area_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_area=', NEW.`id_ai_area`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'area_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'area_trabajo') ELSE CONCAT('MODIFICAR ', 'area_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) ELSE CONCAT('UPDATE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) END,
  JSON_OBJECT('id_ai_area', OLD.`id_ai_area`, 'nombre_area', OLD.`nombre_area`, 'nomeclatura', OLD.`nomeclatura`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.`id_ai_area`, NEW.`id_ai_area`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_area` <=> NEW.`nombre_area`), JSON_OBJECT('nombre_area', JSON_ARRAY(OLD.`nombre_area`, NEW.`nombre_area`)), JSON_OBJECT())), IF(NOT (OLD.`nomeclatura` <=> NEW.`nomeclatura`), JSON_OBJECT('nomeclatura', JSON_ARRAY(OLD.`nomeclatura`, NEW.`nomeclatura`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), 'id_ai_area', NULL), IF(NOT (OLD.`nombre_area` <=> NEW.`nombre_area`), 'nombre_area', NULL), IF(NOT (OLD.`nomeclatura` <=> NEW.`nomeclatura`), 'nomeclatura', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
