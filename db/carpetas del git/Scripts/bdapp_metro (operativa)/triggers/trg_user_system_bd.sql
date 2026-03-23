USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_user_system_bd`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en user_system. Use eliminacion logica (UPDATE user_system SET std_reg=0 ...).'
$$
DELIMITER ;
