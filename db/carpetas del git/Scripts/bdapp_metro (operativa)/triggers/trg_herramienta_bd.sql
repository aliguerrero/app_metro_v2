USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_herramienta_bd`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_bd` BEFORE DELETE ON `herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en herramienta. Use eliminacion logica (UPDATE herramienta SET std_reg=0 ...).'
$$
DELIMITER ;
