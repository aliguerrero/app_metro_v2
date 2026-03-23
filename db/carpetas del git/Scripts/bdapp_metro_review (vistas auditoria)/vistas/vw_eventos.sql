USE `bdapp_metro_review`;

--
-- Estructura para la vista `vw_eventos`
--
DROP VIEW IF EXISTS `vw_eventos`;
DROP TABLE IF EXISTS `vw_eventos`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_eventos`  AS SELECT `information_schema`.`events`.`EVENT_SCHEMA` AS `EVENT_SCHEMA`, `information_schema`.`events`.`EVENT_NAME` AS `EVENT_NAME`, `information_schema`.`events`.`STATUS` AS `STATUS`, `information_schema`.`events`.`INTERVAL_VALUE` AS `INTERVAL_VALUE`, `information_schema`.`events`.`INTERVAL_FIELD` AS `INTERVAL_FIELD`, `information_schema`.`events`.`LAST_EXECUTED` AS `LAST_EXECUTED` FROM `information_schema`.`events` WHERE `information_schema`.`events`.`EVENT_SCHEMA` = 'bdapp_metro_audit' ;
