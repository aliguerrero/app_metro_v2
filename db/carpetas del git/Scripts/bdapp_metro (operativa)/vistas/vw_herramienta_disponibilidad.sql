USE `bdapp_metro`;

--
-- Estructura para la vista `vw_herramienta_disponibilidad`
--
DROP VIEW IF EXISTS `vw_herramienta_disponibilidad`;
DROP TABLE IF EXISTS `vw_herramienta_disponibilidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_herramienta_disponibilidad`  AS SELECT `h`.`id_ai_herramienta` AS `id_ai_herramienta`, `h`.`nombre_herramienta` AS `nombre_herramienta`, `h`.`id_ai_categoria_herramienta` AS `id_ai_categoria_herramienta`, `ch`.`nombre_categoria` AS `nombre_categoria`, `h`.`cantidad` AS `cantidad_total`, coalesce(`occ`.`cantidad_ocupada`,0) AS `cantidad_ocupada`, greatest(`h`.`cantidad` - coalesce(`occ`.`cantidad_ocupada`,0),0) AS `cantidad_disponible`, coalesce(`occ`.`ots_activas`,0) AS `ots_activas`, `h`.`estado` AS `estado`, `h`.`std_reg` AS `std_reg` FROM ((`herramienta` `h` left join `categoria_herramienta` `ch` on(`ch`.`id_ai_categoria_herramienta` = `h`.`id_ai_categoria_herramienta`)) left join (select `hot`.`id_ai_herramienta` AS `id_ai_herramienta`,coalesce(sum(case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`cantidadot` else 0 end),0) AS `cantidad_ocupada`,count(distinct case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`n_ot` end) AS `ots_activas` from `herramientaot` `hot` group by `hot`.`id_ai_herramienta`) `occ` on(`occ`.`id_ai_herramienta` = `h`.`id_ai_herramienta`)) WHERE `h`.`std_reg` = 1 ;
