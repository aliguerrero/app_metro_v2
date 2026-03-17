-- Migracion: tratar user_system.user como campo legado derivado desde empleado
-- Fecha: 2026-03-15

ALTER TABLE `user_system`
    MODIFY COLUMN `user` varchar(100) NOT NULL COMMENT 'Campo legado derivado desde empleado.nombre_empleado; no debe usarse como fuente primaria del nombre visible.';

UPDATE `user_system` u
INNER JOIN `empleado` e
    ON e.`id_empleado` = u.`id_user`
SET u.`user` = e.`nombre_empleado`;
