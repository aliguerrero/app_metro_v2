-- Modulo: Scripts_ddl
-- Archivo: configuracion_correo_smtp.sql
-- Funcion: define la configuracion SMTP utilizada para el envio de correos.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `smtp_config` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `smtp_config`;
CREATE TABLE IF NOT EXISTS `smtp_config` (
  `id` int(11) NOT NULL COMMENT 'Identificador unico de la configuracion SMTP.',
  `enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=habilitado, 0=deshabilitado',
  `provider` varchar(30) NOT NULL DEFAULT 'google' COMMENT 'Proveedor (ej: google)',
  `host` varchar(255) NOT NULL DEFAULT 'smtp.gmail.com' COMMENT 'Servidor SMTP',
  `port` int(11) NOT NULL DEFAULT 587 COMMENT 'Puerto SMTP (587 STARTTLS, 465 SSL)',
  `encryption` enum('tls','ssl','none') NOT NULL DEFAULT 'tls' COMMENT 'Metodo de cifrado',
  `username` varchar(255) NOT NULL DEFAULT '' COMMENT 'Usuario/correo SMTP',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT 'Clave o App Password',
  `from_email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Remitente (From)',
  `from_name` varchar(255) DEFAULT NULL COMMENT 'Nombre remitente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de creacion del registro SMTP.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha y hora de ultima actualizacion del registro SMTP.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `smtp_config`.
-- -----------------------------------------------------------------------------
ALTER TABLE `smtp_config`
  ADD PRIMARY KEY (`id`);

