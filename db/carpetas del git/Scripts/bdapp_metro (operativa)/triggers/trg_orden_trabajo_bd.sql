USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_orden_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_bd` BEFORE DELETE ON `orden_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en orden_trabajo. Use eliminacion logica (UPDATE orden_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;
