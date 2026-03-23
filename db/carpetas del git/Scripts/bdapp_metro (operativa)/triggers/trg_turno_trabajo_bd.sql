USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_turno_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_bd` BEFORE DELETE ON `turno_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en turno_trabajo. Use eliminacion logica (UPDATE turno_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;
