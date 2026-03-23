USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_reporte_generado_bd`;
DELIMITER $$
CREATE TRIGGER `trg_reporte_generado_bd` BEFORE DELETE ON `reporte_generado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).'
$$
DELIMITER ;
