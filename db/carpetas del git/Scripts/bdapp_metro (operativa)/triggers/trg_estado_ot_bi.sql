USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_estado_ot_bi`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bi` BEFORE INSERT ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;
END
$$
DELIMITER ;
