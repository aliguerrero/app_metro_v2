USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_log_user_no_update`;
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_update` BEFORE UPDATE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite modificar registros de auditoría (log_user).'
$$
DELIMITER ;
