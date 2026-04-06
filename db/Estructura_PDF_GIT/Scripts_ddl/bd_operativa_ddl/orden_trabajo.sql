-- Modulo: Scripts_ddl
-- Archivo: orden_trabajo.sql
-- Funcion: define el encabezado principal de las ordenes de trabajo y sus vistas de consulta.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `orden_trabajo` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `orden_trabajo`;
CREATE TABLE IF NOT EXISTS `orden_trabajo` (
  `id_ai_ot` int(11) NOT NULL COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `id_ai_area` int(11) NOT NULL COMMENT 'Area de trabajo responsable de la orden',
  `id_user` varchar(30) NOT NULL COMMENT 'Identificador unico del usuario del sistema',
  `id_ai_sitio` int(11) NOT NULL COMMENT 'Identificador unico del sitio de trabajo',
  `id_ai_estado` int(11) NOT NULL COMMENT 'Estado operativo actual de la orden de trabajo',
  `nombre_trab` varchar(500) NOT NULL COMMENT 'Descripcion o nombre del trabajo a realizar',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `semana` varchar(100) NOT NULL COMMENT 'Semana del ano correspondiente a la orden',
  `mes` varchar(100) NOT NULL COMMENT 'Mes correspondiente a la orden de trabajo',
  `ot_finalizada` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si la orden de trabajo fue finalizada (1=si, 0=no).',
  `fecha_finalizacion` datetime DEFAULT NULL COMMENT 'Fecha y hora en que se finalizo la orden de trabajo.',
  `id_user_finaliza` varchar(30) DEFAULT NULL COMMENT 'Identificador unico del usuario que finalizo la orden de trabajo.',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_orden_trabajo_ai` concentra la logica definida para la insercion sobre `orden_trabajo` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_ai` AFTER INSERT ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    'INSERT',
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    'CREAR orden_trabajo',
    CONCAT('INSERT orden_trabajo n_ot=', NEW.n_ot),
    NULL,
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    'id_ai_ot,n_ot,id_ai_area,id_user,id_ai_sitio,id_ai_estado,nombre_trab,fecha,semana,mes,ot_finalizada,fecha_finalizacion,id_user_finaliza,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_orden_trabajo_au` concentra la logica definida para la actualizacion sobre `orden_trabajo` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_au` AFTER UPDATE ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'SOFT_DELETE'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'RESTORE'
      ELSE 'UPDATE'
    END,
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'ELIMINAR (LOGICO) orden_trabajo'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'REACTIVAR orden_trabajo'
      ELSE 'MODIFICAR orden_trabajo'
    END,
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN CONCAT('SOFT_DELETE orden_trabajo n_ot=', NEW.n_ot)
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN CONCAT('RESTORE orden_trabajo n_ot=', NEW.n_ot)
      ELSE CONCAT('UPDATE orden_trabajo n_ot=', NEW.n_ot)
    END,
    JSON_OBJECT(
      'id_ai_ot', OLD.id_ai_ot,
      'n_ot', OLD.n_ot,
      'id_ai_area', OLD.id_ai_area,
      'id_user', OLD.id_user,
      'id_ai_sitio', OLD.id_ai_sitio,
      'id_ai_estado', OLD.id_ai_estado,
      'nombre_trab', OLD.nombre_trab,
      'fecha', OLD.fecha,
      'semana', OLD.semana,
      'mes', OLD.mes,
      'ot_finalizada', OLD.ot_finalizada,
      'fecha_finalizacion', OLD.fecha_finalizacion,
      'id_user_finaliza', OLD.id_user_finaliza,
      'std_reg', OLD.std_reg
    ),
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_MERGE_PATCH(
                JSON_MERGE_PATCH(
                  JSON_MERGE_PATCH(
                    JSON_MERGE_PATCH(
                      JSON_MERGE_PATCH(
                        JSON_MERGE_PATCH(
                          JSON_MERGE_PATCH(
                            JSON_MERGE_PATCH(
                              JSON_OBJECT(),
                              IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), JSON_OBJECT('id_ai_ot', JSON_ARRAY(OLD.id_ai_ot, NEW.id_ai_ot)), JSON_OBJECT())
                            ),
                            IF(NOT (OLD.n_ot <=> NEW.n_ot), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.n_ot, NEW.n_ot)), JSON_OBJECT())
                          ),
                          IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.id_ai_area, NEW.id_ai_area)), JSON_OBJECT())
                        ),
                        IF(NOT (OLD.id_user <=> NEW.id_user), JSON_OBJECT('id_user', JSON_ARRAY(OLD.id_user, NEW.id_user)), JSON_OBJECT())
                      ),
                      IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.id_ai_sitio, NEW.id_ai_sitio)), JSON_OBJECT())
                    ),
                    IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.id_ai_estado, NEW.id_ai_estado)), JSON_OBJECT())
                  ),
                  IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), JSON_OBJECT('nombre_trab', JSON_ARRAY(OLD.nombre_trab, NEW.nombre_trab)), JSON_OBJECT())
                ),
                IF(NOT (OLD.fecha <=> NEW.fecha), JSON_OBJECT('fecha', JSON_ARRAY(OLD.fecha, NEW.fecha)), JSON_OBJECT())
              ),
              IF(NOT (OLD.semana <=> NEW.semana), JSON_OBJECT('semana', JSON_ARRAY(OLD.semana, NEW.semana)), JSON_OBJECT())
            ),
            IF(NOT (OLD.mes <=> NEW.mes), JSON_OBJECT('mes', JSON_ARRAY(OLD.mes, NEW.mes)), JSON_OBJECT())
          ),
          IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), JSON_OBJECT('ot_finalizada', JSON_ARRAY(OLD.ot_finalizada, NEW.ot_finalizada)), JSON_OBJECT())
        ),
        JSON_MERGE_PATCH(
          IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), JSON_OBJECT('fecha_finalizacion', JSON_ARRAY(OLD.fecha_finalizacion, NEW.fecha_finalizacion)), JSON_OBJECT()),
          IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), JSON_OBJECT('id_user_finaliza', JSON_ARRAY(OLD.id_user_finaliza, NEW.id_user_finaliza)), JSON_OBJECT())
        )
      ),
      IF(NOT (OLD.std_reg <=> NEW.std_reg), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.std_reg, NEW.std_reg)), JSON_OBJECT())
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), 'id_ai_ot', NULL),
        IF(NOT (OLD.n_ot <=> NEW.n_ot), 'n_ot', NULL),
        IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), 'id_ai_area', NULL),
        IF(NOT (OLD.id_user <=> NEW.id_user), 'id_user', NULL),
        IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), 'id_ai_sitio', NULL),
        IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), 'id_ai_estado', NULL),
        IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), 'nombre_trab', NULL),
        IF(NOT (OLD.fecha <=> NEW.fecha), 'fecha', NULL),
        IF(NOT (OLD.semana <=> NEW.semana), 'semana', NULL),
        IF(NOT (OLD.mes <=> NEW.mes), 'mes', NULL),
        IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), 'ot_finalizada', NULL),
        IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), 'fecha_finalizacion', NULL),
        IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), 'id_user_finaliza', NULL),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), 'std_reg', NULL)
      ),
      ''
    ),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_orden_trabajo_bd` valida o bloquea la eliminacion en `orden_trabajo` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_bd` BEFORE DELETE ON `orden_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en orden_trabajo. Use eliminacion logica (UPDATE orden_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `orden_trabajo`.
-- -----------------------------------------------------------------------------
ALTER TABLE `orden_trabajo`
  ADD PRIMARY KEY (`id_ai_ot`),
  ADD UNIQUE KEY `n_ot` (`n_ot`),
  ADD KEY `status` (`std_reg`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `sitio_trab` (`id_ai_sitio`),
  ADD KEY `id_area` (`id_ai_area`),
  ADD KEY `idx_orden_trabajo_finalizada` (`ot_finalizada`,`std_reg`),
  ADD KEY `idx_orden_trabajo_estado` (`id_ai_estado`,`std_reg`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `orden_trabajo` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `orden_trabajo`
  MODIFY `id_ai_ot` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=9;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `orden_trabajo` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `orden_trabajo`
  ADD CONSTRAINT `orden_trabajo_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orden_trabajo_ibfk_2` FOREIGN KEY (`id_ai_sitio`) REFERENCES `sitio_trabajo` (`id_ai_sitio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orden_trabajo_ibfk_3` FOREIGN KEY (`id_ai_area`) REFERENCES `area_trabajo` (`id_ai_area`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orden_trabajo_ibfk_4` FOREIGN KEY (`id_ai_estado`) REFERENCES `estado_ot` (`id_ai_estado`) ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- muestra el detalle ampliado de cada orden de trabajo con responsables, sitio, estado y turnos.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_ot_detallada`;
DROP TABLE IF EXISTS `vw_ot_detallada`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_ot_detallada`  AS SELECT `det`.`id_ai_detalle` AS `id_ai_detalle`, `det`.`n_ot` AS `n_ot`, `ot`.`id_ai_ot` AS `id_ai_ot`, `ot`.`fecha` AS `fecha_ot`, `ot`.`nombre_trab` AS `nombre_trab`, `ot`.`semana` AS `semana`, `ot`.`mes` AS `mes`, `ot`.`id_ai_area` AS `id_ai_area`, `area`.`nombre_area` AS `nombre_area`, `area`.`nomeclatura` AS `area_nomeclatura`, `ot`.`id_ai_sitio` AS `id_ai_sitio`, `sitio`.`nombre_sitio` AS `nombre_sitio`, `ot`.`id_ai_estado` AS `id_ai_estado`, `eo`.`nombre_estado` AS `estado_ot`, `eo`.`color` AS `color_estado_ot`, coalesce(`eo`.`libera_herramientas`,0) AS `libera_herramientas`, coalesce(`eo`.`bloquea_ot`,0) AS `bloquea_ot`, `det`.`fecha` AS `fecha_detalle`, `det`.`descripcion` AS `descripcion`, `det`.`id_ai_turno` AS `id_ai_turno`, `tt`.`nombre_turno` AS `nombre_turno`, `det`.`id_user_act` AS `id_user_act`, `us_det`.`username` AS `username_usuario_act`, `emp_det`.`nombre_empleado` AS `usuario_act_nombre`, `det`.`id_miembro_cco` AS `id_miembro_cco`, `mcco`.`nombre_miembro` AS `miembro_cco_nombre`, `det`.`id_miembro_ccf` AS `id_miembro_ccf`, `mccf`.`nombre_miembro` AS `miembro_ccf_nombre`, `det`.`cant_tec` AS `cant_tec`, `det`.`hora_inicio` AS `hora_inicio`, `det`.`hora_fin` AS `hora_fin`, `det`.`observacion` AS `observacion`, coalesce(`ot`.`ot_finalizada`,0) AS `ot_finalizada` FROM (((((((((`detalle_orden` `det` join `orden_trabajo` `ot` on(`ot`.`n_ot` = `det`.`n_ot` and `ot`.`std_reg` = 1)) left join `area_trabajo` `area` on(`area`.`id_ai_area` = `ot`.`id_ai_area`)) left join `sitio_trabajo` `sitio` on(`sitio`.`id_ai_sitio` = `ot`.`id_ai_sitio`)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join `turno_trabajo` `tt` on(`tt`.`id_ai_turno` = `det`.`id_ai_turno`)) left join `user_system` `us_det` on(`us_det`.`id_empleado` = `det`.`id_user_act`)) left join `empleado` `emp_det` on(`emp_det`.`id_empleado` = `det`.`id_user_act`)) left join `miembro` `mcco` on(`mcco`.`id_miembro` = `det`.`id_miembro_cco`)) left join `miembro` `mccf` on(`mccf`.`id_miembro` = `det`.`id_miembro_ccf`)) ;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- resume cada orden de trabajo con estado, responsables y conteos operativos asociados.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_ot_resumen`;
DROP TABLE IF EXISTS `vw_ot_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_ot_resumen`  AS SELECT `ot`.`id_ai_ot` AS `id_ai_ot`, `ot`.`n_ot` AS `n_ot`, `ot`.`fecha` AS `fecha`, `ot`.`semana` AS `semana`, `ot`.`mes` AS `mes`, `ot`.`nombre_trab` AS `nombre_trab`, `ot`.`id_ai_area` AS `id_ai_area`, `area`.`nombre_area` AS `nombre_area`, `area`.`nomeclatura` AS `area_nomeclatura`, `ot`.`id_ai_sitio` AS `id_ai_sitio`, `sitio`.`nombre_sitio` AS `nombre_sitio`, `ot`.`id_ai_estado` AS `id_ai_estado`, `eo`.`nombre_estado` AS `nombre_estado`, `eo`.`color` AS `color_estado`, coalesce(`eo`.`libera_herramientas`,0) AS `libera_herramientas`, coalesce(`eo`.`bloquea_ot`,0) AS `bloquea_ot`, coalesce(`ot`.`ot_finalizada`,0) AS `ot_finalizada`, `ot`.`fecha_finalizacion` AS `fecha_finalizacion`, `ot`.`id_user_finaliza` AS `id_user_finaliza`, `ot`.`id_user` AS `id_user_responsable`, `us`.`username` AS `username_responsable`, `emp`.`nombre_empleado` AS `empleado_responsable`, `emp`.`telefono` AS `telefono_responsable`, `emp`.`correo` AS `correo_responsable`, coalesce(`det`.`total_detalles`,0) AS `total_detalles`, coalesce(`hot`.`herramientas_asignadas`,0) AS `herramientas_asignadas`, coalesce(`hot`.`herramientas_activas`,0) AS `herramientas_activas`, `ot`.`std_reg` AS `std_reg` FROM (((((((`orden_trabajo` `ot` left join `area_trabajo` `area` on(`area`.`id_ai_area` = `ot`.`id_ai_area`)) left join `sitio_trabajo` `sitio` on(`sitio`.`id_ai_sitio` = `ot`.`id_ai_sitio`)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join `user_system` `us` on(`us`.`id_empleado` = `ot`.`id_user`)) left join `empleado` `emp` on(`emp`.`id_empleado` = `ot`.`id_user`)) left join (select `detalle_orden`.`n_ot` AS `n_ot`,count(0) AS `total_detalles` from `detalle_orden` group by `detalle_orden`.`n_ot`) `det` on(`det`.`n_ot` = `ot`.`n_ot`)) left join (select `herramientaot`.`n_ot` AS `n_ot`,coalesce(sum(`herramientaot`.`cantidadot`),0) AS `herramientas_asignadas`,coalesce(sum(case when coalesce(`herramientaot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `herramientaot`.`cantidadot` else 0 end),0) AS `herramientas_activas` from `herramientaot` group by `herramientaot`.`n_ot`) `hot` on(`hot`.`n_ot` = `ot`.`n_ot`)) WHERE `ot`.`std_reg` = 1 ;

