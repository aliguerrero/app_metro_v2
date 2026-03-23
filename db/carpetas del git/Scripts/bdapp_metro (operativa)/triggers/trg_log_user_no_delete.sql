USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_log_user_no_delete`;
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_delete` BEFORE DELETE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoria (log_user).'
$$
DELIMITER ;
