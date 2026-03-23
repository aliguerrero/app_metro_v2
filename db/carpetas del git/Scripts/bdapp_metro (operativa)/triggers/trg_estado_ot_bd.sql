USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_estado_ot_bd`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bd` BEFORE DELETE ON `estado_ot` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en estado_ot. Use eliminacion logica (UPDATE estado_ot SET std_reg=0 ...).'
$$
DELIMITER ;
