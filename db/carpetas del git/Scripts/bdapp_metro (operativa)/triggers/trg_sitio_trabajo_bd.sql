USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_sitio_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_bd` BEFORE DELETE ON `sitio_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en sitio_trabajo. Use eliminacion logica (UPDATE sitio_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;
