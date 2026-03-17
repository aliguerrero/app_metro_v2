-- Crea tabla de configuracion SMTP (Google/Gmail) para el sistema
-- Ejecutar en la BD `bdapp_metro` con una cuenta con privilegios DDL.

CREATE TABLE IF NOT EXISTS `smtp_config` (
  `id` int(11) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=habilitado, 0=deshabilitado',
  `provider` varchar(30) NOT NULL DEFAULT 'google' COMMENT 'Proveedor (ej: google)',
  `host` varchar(255) NOT NULL DEFAULT 'smtp.gmail.com' COMMENT 'Servidor SMTP',
  `port` int(11) NOT NULL DEFAULT 587 COMMENT 'Puerto SMTP (587 STARTTLS, 465 SSL)',
  `encryption` enum('tls','ssl','none') NOT NULL DEFAULT 'tls' COMMENT 'Metodo de cifrado',
  `username` varchar(255) NOT NULL DEFAULT '' COMMENT 'Usuario/correo SMTP',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT 'Clave o App Password',
  `from_email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Remitente (From)',
  `from_name` varchar(255) DEFAULT NULL COMMENT 'Nombre remitente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `smtp_config`
  ADD PRIMARY KEY (`id`);

-- Fila base (id=1). Si ya existe, mantiene valores actuales salvo defaults de host/puerto/cifrado/proveedor.
INSERT INTO `smtp_config` (`id`, `enabled`, `provider`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`)
VALUES (1, 0, 'google', 'smtp.gmail.com', 587, 'tls', '', '', '', NULL)
ON DUPLICATE KEY UPDATE
  `provider` = VALUES(`provider`),
  `host` = VALUES(`host`),
  `port` = VALUES(`port`),
  `encryption` = VALUES(`encryption`);

