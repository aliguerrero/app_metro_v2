START TRANSACTION;

CREATE TABLE IF NOT EXISTS `categoria_empleado` (
  `id_ai_categoria_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria del empleado',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_categoria_empleado`),
  UNIQUE KEY `uk_categoria_empleado_nombre` (`nombre_categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `empleado` (
  `id_ai_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador unico del empleado',
  `nombre_empleado` varchar(100) NOT NULL COMMENT 'Nombre completo del empleado',
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'Categoria asociada al empleado',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_empleado`),
  UNIQUE KEY `uk_empleado_codigo` (`id_empleado`),
  KEY `idx_empleado_categoria` (`id_ai_categoria_empleado`),
  CONSTRAINT `fk_empleado_categoria` FOREIGN KEY (`id_ai_categoria_empleado`) REFERENCES `categoria_empleado` (`id_ai_categoria_empleado`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `categoria_empleado` (`nombre_categoria`, `descripcion`, `std_reg`)
SELECT 'SIN CATEGORIA', 'Categoria por defecto para la migracion de usuarios existentes.', 1
WHERE NOT EXISTS (
  SELECT 1
  FROM `categoria_empleado`
  WHERE UPPER(`nombre_categoria`) = 'SIN CATEGORIA'
);

SET @default_categoria_empleado := (
  SELECT `id_ai_categoria_empleado`
  FROM `categoria_empleado`
  WHERE UPPER(`nombre_categoria`) = 'SIN CATEGORIA'
  ORDER BY `id_ai_categoria_empleado`
  LIMIT 1
);

INSERT INTO `empleado` (`id_empleado`, `nombre_empleado`, `id_ai_categoria_empleado`, `std_reg`)
SELECT
  u.`id_user`,
  COALESCE(NULLIF(TRIM(u.`user`), ''), u.`username`),
  @default_categoria_empleado,
  u.`std_reg`
FROM `user_system` u
LEFT JOIN `empleado` e
  ON e.`id_empleado` = u.`id_user`
WHERE e.`id_ai_empleado` IS NULL;

SET @fk_user_system_empleado_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'user_system'
    AND CONSTRAINT_NAME = 'fk_user_system_empleado'
);

SET @fk_user_system_empleado_sql := IF(
  @fk_user_system_empleado_exists = 0,
  'ALTER TABLE `user_system` ADD CONSTRAINT `fk_user_system_empleado` FOREIGN KEY (`id_user`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE',
  'SELECT 1'
);

PREPARE stmt_fk_user_system_empleado FROM @fk_user_system_empleado_sql;
EXECUTE stmt_fk_user_system_empleado;
DEALLOCATE PREPARE stmt_fk_user_system_empleado;

UPDATE `user_system` u
INNER JOIN `empleado` e
  ON e.`id_empleado` = u.`id_user`
SET u.`user` = e.`nombre_empleado`;

COMMIT;
