USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_area_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_bd` BEFORE DELETE ON `area_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en area_trabajo. Use eliminacion logica (UPDATE area_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;
