USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_categoria_empleado_bd`;
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_bd` BEFORE DELETE ON `categoria_empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_empleado. Use eliminacion logica (UPDATE categoria_empleado SET std_reg=0 ...).'
$$
DELIMITER ;
