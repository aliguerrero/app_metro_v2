USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_empleado_bd`;
DELIMITER $$
CREATE TRIGGER `trg_empleado_bd` BEFORE DELETE ON `empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).'
$$
DELIMITER ;
