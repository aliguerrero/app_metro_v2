-- Modulo: Scripts_dml
-- Archivo: configuracion_empresa.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a la configuracion empresarial.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `empresa_config` (`id`, `nombre`, `rif`, `direccion`, `telefono`, `email`, `logo`, `created_at`, `updated_at`) VALUES
(1, 'C.A. Metro Valencia', 'G-0000000-1', 'Av. Sesquicentenaria, local Parque Recreacional Sur, parte Sur Oeste Nro. S/N, zona Valencia Sur. Estado Carabobo.', '0241-0000000', 'metrodevalencia@correo.com', 'app/views/img/empresa/logo_empresa.jpg', '2026-01-07 20:59:31', '2026-02-11 23:26:46');
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: configuracion_empresa / actualizar
-- documenta la operacion 'actualizar' del modulo 'configuracion_empresa' segun el codigo fuente indicado en app/controllers/empresaConfigController.php -> actualizarEmpresaControlador.
-- -----------------------------------------------------------------------------
SELECT logo FROM empresa_config WHERE id = 1 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: configuracion_empresa / actualizar
-- documenta la operacion 'actualizar' del modulo 'configuracion_empresa' segun el codigo fuente indicado en app/controllers/empresaConfigController.php -> actualizarEmpresaControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE empresa_config SET nombre = :nombre, rif = :rif, direccion = :direccion, telefono = :telefono, email = :email WHERE id = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: configuracion_empresa / listar
-- documenta la operacion 'listar' del modulo 'configuracion_empresa' segun el codigo fuente indicado en app/controllers/empresaConfigController.php -> obtenerEmpresaControlador.
-- -----------------------------------------------------------------------------
SELECT `id`, `nombre`, `rif`, `direccion`, `telefono`, `email`, `logo`, `created_at`, `updated_at` FROM empresa_config WHERE id = 1 LIMIT 1;

