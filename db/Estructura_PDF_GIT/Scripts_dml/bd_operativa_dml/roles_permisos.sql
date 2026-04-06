-- Modulo: Scripts_dml
-- Archivo: roles_permisos.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los roles y permisos.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `roles_permisos` (`id`, `nombre_rol`, `perm_usuarios_view`, `perm_usuarios_add`, `perm_usuarios_edit`, `perm_usuarios_delete`, `perm_herramienta_view`, `perm_herramienta_add`, `perm_herramienta_edit`, `perm_herramienta_delete`, `perm_miembro_view`, `perm_miembro_add`, `perm_miembro_edit`, `perm_miembro_delete`, `perm_ot_view`, `perm_ot_add`, `perm_ot_edit`, `perm_ot_delete`, `perm_ot_add_detalle`, `perm_ot_generar_reporte`, `perm_ot_add_herramienta`) VALUES
(1, 'ROOT', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(18, 'SUPERVISOR', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(19, 'OPERADOR', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarRolRoot.
-- -----------------------------------------------------------------------------
SELECT id FROM roles_permisos WHERE id = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarRolRoot.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE roles_permisos
                 SET nombre_rol = :nombre_rol, `perm_usuarios_view` = :perm_usuarios_view, `perm_usuarios_add` = :perm_usuarios_add, `perm_usuarios_edit` = :perm_usuarios_edit, `perm_usuarios_delete` = :perm_usuarios_delete, `perm_herramienta_view` = :perm_herramienta_view, `perm_herramienta_add` = :perm_herramienta_add, `perm_herramienta_edit` = :perm_herramienta_edit, `perm_herramienta_delete` = :perm_herramienta_delete, `perm_miembro_view` = :perm_miembro_view, `perm_miembro_add` = :perm_miembro_add, `perm_miembro_edit` = :perm_miembro_edit, `perm_miembro_delete` = :perm_miembro_delete, `perm_ot_view` = :perm_ot_view, `perm_ot_add` = :perm_ot_add, `perm_ot_edit` = :perm_ot_edit, `perm_ot_delete` = :perm_ot_delete, `perm_ot_add_detalle` = :perm_ot_add_detalle, `perm_ot_generar_reporte` = :perm_ot_generar_reporte, `perm_ot_add_herramienta` = :perm_ot_add_herramienta
                 WHERE id = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarRolRoot.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO roles_permisos (
                    id,
                    nombre_rol, `perm_usuarios_view`, `perm_usuarios_add`, `perm_usuarios_edit`, `perm_usuarios_delete`, `perm_herramienta_view`, `perm_herramienta_add`, `perm_herramienta_edit`, `perm_herramienta_delete`, `perm_miembro_view`, `perm_miembro_add`, `perm_miembro_edit`, `perm_miembro_delete`, `perm_ot_view`, `perm_ot_add`, `perm_ot_edit`, `perm_ot_delete`, `perm_ot_add_detalle`, `perm_ot_generar_reporte`, `perm_ot_add_herramienta`
                ) VALUES (
                    :id,
                    :nombre_rol, :perm_usuarios_view, :perm_usuarios_add, :perm_usuarios_edit, :perm_usuarios_delete, :perm_herramienta_view, :perm_herramienta_add, :perm_herramienta_edit, :perm_herramienta_delete, :perm_miembro_view, :perm_miembro_add, :perm_miembro_edit, :perm_miembro_delete, :perm_ot_view, :perm_ot_add, :perm_ot_edit, :perm_ot_delete, :perm_ot_add_detalle, :perm_ot_generar_reporte, :perm_ot_add_herramienta
                );
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: roles / actualizar
-- documenta la operacion 'actualizar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
SELECT id FROM roles_permisos WHERE nombre_rol = :n LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: roles / actualizar
-- documenta la operacion 'actualizar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
SELECT id FROM roles_permisos WHERE nombre_rol = :n ORDER BY id DESC LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: roles / actualizar
-- documenta la operacion 'actualizar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
SELECT `id`, `nombre_rol`, `perm_usuarios_view`, `perm_usuarios_add`, `perm_usuarios_edit`, `perm_usuarios_delete`, `perm_herramienta_view`, `perm_herramienta_add`, `perm_herramienta_edit`, `perm_herramienta_delete`, `perm_miembro_view`, `perm_miembro_add`, `perm_miembro_edit`, `perm_miembro_delete`, `perm_ot_view`, `perm_ot_add`, `perm_ot_edit`, `perm_ot_delete`, `perm_ot_add_detalle`, `perm_ot_generar_reporte`, `perm_ot_add_herramienta` FROM roles_permisos WHERE id = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: roles / actualizar
-- documenta la operacion 'actualizar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE roles_permisos SET
            perm_usuarios_view        = :puv,
            perm_usuarios_add         = :pua,
            perm_usuarios_edit        = :pue,
            perm_usuarios_delete      = :pud,

            perm_herramienta_view     = :phv,
            perm_herramienta_add      = :pha,
            perm_herramienta_edit     = :phe,
            perm_herramienta_delete   = :phd,

            perm_miembro_view         = :pmv,
            perm_miembro_add          = :pma,
            perm_miembro_edit         = :pme,
            perm_miembro_delete       = :pmd,

            perm_ot_view              = :potv,
            perm_ot_add               = :pota,
            perm_ot_edit              = :pote,
            perm_ot_delete            = :potd,

            perm_ot_add_detalle       = :potad,
            perm_ot_generar_reporte   = :potgr,
            perm_ot_add_herramienta   = :potah
        WHERE id = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: roles / crear
-- documenta la operacion 'crear' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO roles_permisos (
                    nombre_rol,
                    perm_usuarios_view, perm_usuarios_add, perm_usuarios_edit, perm_usuarios_delete,
                    perm_herramienta_view, perm_herramienta_add, perm_herramienta_edit, perm_herramienta_delete,
                    perm_miembro_view, perm_miembro_add, perm_miembro_edit, perm_miembro_delete,
                    perm_ot_view, perm_ot_add, perm_ot_edit, perm_ot_delete,
                    perm_ot_add_detalle, perm_ot_generar_reporte, perm_ot_add_herramienta
                ) VALUES (
                    :nombre,
                    :puv, :pua, :pue, :pud,
                    :phv, :pha, :phe, :phd,
                    :pmv, :pma, :pme, :pmd,
                    :potv, :pota, :pote, :potd,
                    :potad, :potgr, :potah
                );
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: roles / eliminar
-- documenta la operacion 'eliminar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/rolCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
DELETE FROM roles_permisos WHERE id = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: roles / listar
-- documenta la operacion 'listar' del modulo 'roles' segun el codigo fuente indicado en app/controllers/configController.php -> listarComboRolControlador.
-- -----------------------------------------------------------------------------
SELECT `id`, `nombre_rol`, `perm_usuarios_view`, `perm_usuarios_add`, `perm_usuarios_edit`, `perm_usuarios_delete`, `perm_herramienta_view`, `perm_herramienta_add`, `perm_herramienta_edit`, `perm_herramienta_delete`, `perm_miembro_view`, `perm_miembro_add`, `perm_miembro_edit`, `perm_miembro_delete`, `perm_ot_view`, `perm_ot_add`, `perm_ot_edit`, `perm_ot_delete`, `perm_ot_add_detalle`, `perm_ot_generar_reporte`, `perm_ot_add_herramienta` FROM roles_permisos where id != 1 ORDER BY nombre_rol ASC;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> existeRol.
-- -----------------------------------------------------------------------------
SELECT 1 FROM roles_permisos WHERE id = :id LIMIT 1;

