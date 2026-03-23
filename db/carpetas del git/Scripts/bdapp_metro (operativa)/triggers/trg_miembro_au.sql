USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_miembro_au`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_au` AFTER UPDATE ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'miembro',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'miembro') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'miembro') ELSE CONCAT('MODIFICAR ', 'miembro') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) ELSE CONCAT('UPDATE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) END,
  JSON_OBJECT('id_ai_miembro', OLD.`id_ai_miembro`, 'id_miembro', OLD.`id_miembro`, 'nombre_miembro', OLD.`nombre_miembro`, 'tipo_miembro', OLD.`tipo_miembro`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_miembro` <=> NEW.`id_ai_miembro`), JSON_OBJECT('id_ai_miembro', JSON_ARRAY(OLD.`id_ai_miembro`, NEW.`id_ai_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`id_miembro` <=> NEW.`id_miembro`), JSON_OBJECT('id_miembro', JSON_ARRAY(OLD.`id_miembro`, NEW.`id_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_miembro` <=> NEW.`nombre_miembro`), JSON_OBJECT('nombre_miembro', JSON_ARRAY(OLD.`nombre_miembro`, NEW.`nombre_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`tipo_miembro` <=> NEW.`tipo_miembro`), JSON_OBJECT('tipo_miembro', JSON_ARRAY(OLD.`tipo_miembro`, NEW.`tipo_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_miembro` <=> NEW.`id_ai_miembro`), 'id_ai_miembro', NULL), IF(NOT (OLD.`id_miembro` <=> NEW.`id_miembro`), 'id_miembro', NULL), IF(NOT (OLD.`nombre_miembro` <=> NEW.`nombre_miembro`), 'nombre_miembro', NULL), IF(NOT (OLD.`tipo_miembro` <=> NEW.`tipo_miembro`), 'tipo_miembro', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
