USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_categoria_herramienta_bd`;
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_bd` BEFORE DELETE ON `categoria_herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_herramienta. Use eliminacion logica (UPDATE categoria_herramienta SET std_reg=0 ...).'
$$
DELIMITER ;
