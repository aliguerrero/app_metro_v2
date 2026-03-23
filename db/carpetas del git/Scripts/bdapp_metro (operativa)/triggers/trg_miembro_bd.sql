USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_miembro_bd`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_bd` BEFORE DELETE ON `miembro` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en miembro. Use eliminacion logica (UPDATE miembro SET std_reg=0 ...).'
$$
DELIMITER ;
