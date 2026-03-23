USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_estado_ot_bu`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bu` BEFORE UPDATE ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
        AND id_ai_estado <> OLD.id_ai_estado
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;

  IF COALESCE(OLD.bloquea_ot, 0) = 1
     AND (
       NOT (OLD.nombre_estado <=> NEW.nombre_estado)
       OR NOT (OLD.color <=> NEW.color)
       OR NOT (OLD.libera_herramientas <=> NEW.libera_herramientas)
       OR NOT (OLD.bloquea_ot <=> NEW.bloquea_ot)
       OR NOT (OLD.std_reg <=> NEW.std_reg)
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El estado configurado para bloquear la O.T. es protegido y no puede modificarse ni eliminarse.';
  END IF;
END
$$
DELIMITER ;
