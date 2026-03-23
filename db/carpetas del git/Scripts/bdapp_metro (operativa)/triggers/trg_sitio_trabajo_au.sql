USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_sitio_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_au` AFTER UPDATE ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'sitio_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'sitio_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'sitio_trabajo') ELSE CONCAT('MODIFICAR ', 'sitio_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) ELSE CONCAT('UPDATE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) END,
  JSON_OBJECT('id_ai_sitio', OLD.`id_ai_sitio`, 'nombre_sitio', OLD.`nombre_sitio`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.`id_ai_sitio`, NEW.`id_ai_sitio`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_sitio` <=> NEW.`nombre_sitio`), JSON_OBJECT('nombre_sitio', JSON_ARRAY(OLD.`nombre_sitio`, NEW.`nombre_sitio`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), 'id_ai_sitio', NULL), IF(NOT (OLD.`nombre_sitio` <=> NEW.`nombre_sitio`), 'nombre_sitio', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
