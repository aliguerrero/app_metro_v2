-- Modulo: Scripts_dml
-- Archivo: usuario_sistema.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los usuarios del sistema y su autenticacion.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `user_system` (`id_ai_user`, `id_empleado`, `username`, `password`, `failed_login_attempts`, `account_locked`, `locked_at`, `password_reset_required`, `last_login_at`, `last_login_ip`, `tipo`, `std_reg`) VALUES
(1, '22206460', 'administrador', '$2y$10$4XbvzXDX8rqEcvTEFytGsOjjKT5JiWaCOCO74J0dRda7gRsEU0vAW', 0, 0, NULL, 0, NULL, NULL, 1, 1),
(2, '8840285', 'manuel', '$2y$10$lxd/rybwToLb3Db1sG60fud56CayMxaMy/VOpwhBb0WZwG7v/uOY.', 0, 0, NULL, 0, '2026-03-22 16:27:14', '::1', 18, 1),
(4, '26580187', 'walter', '$2y$10$IwC3zzWb.by5LYUIpsLc..PNokUdad2bjT59LsOFO1pQqRrEL9A6W', 0, 0, NULL, 0, NULL, NULL, 19, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> sistemaRequiereBootstrapControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(*) FROM user_system WHERE std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_user, id_empleado, username
                 FROM user_system
                 WHERE id_empleado = :id_empleado
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_user, id_empleado, username
                 FROM user_system
                 WHERE username = :username
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system
                     SET id_empleado = :id_empleado,
                         username = :username,
                         password = :password,
                         failed_login_attempts = 0,
                         account_locked = 0,
                         locked_at = NULL,
                         password_reset_required = 0,
                         last_login_at = NULL,
                         last_login_ip = NULL,
                         tipo = :tipo,
                         std_reg = 1
                     WHERE id_ai_user = :id_ai_user;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO user_system (
                        id_empleado,
                        username,
                        password,
                        failed_login_attempts,
                        account_locked,
                        locked_at,
                        password_reset_required,
                        last_login_at,
                        last_login_ip,
                        tipo,
                        std_reg
                     ) VALUES (
                        :id_empleado,
                        :username,
                        :password,
                        0,
                        0,
                        NULL,
                        0,
                        NULL,
                        NULL,
                        :tipo,
                        1
                     );
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> cargarUsuarioAuthPorUsername.
-- -----------------------------------------------------------------------------
SELECT
                `u`.`id_ai_user`, `u`.`id_empleado`, `u`.`username`, `u`.`password`, `u`.`failed_login_attempts`, `u`.`account_locked`, `u`.`locked_at`, `u`.`password_reset_required`, `u`.`last_login_at`, `u`.`last_login_ip`, `u`.`tipo`, `u`.`std_reg`,
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                e.correo,
                `r`.`id`, `r`.`nombre_rol`, `r`.`perm_usuarios_view`, `r`.`perm_usuarios_add`, `r`.`perm_usuarios_edit`, `r`.`perm_usuarios_delete`, `r`.`perm_herramienta_view`, `r`.`perm_herramienta_add`, `r`.`perm_herramienta_edit`, `r`.`perm_herramienta_delete`, `r`.`perm_miembro_view`, `r`.`perm_miembro_add`, `r`.`perm_miembro_edit`, `r`.`perm_miembro_delete`, `r`.`perm_ot_view`, `r`.`perm_ot_add`, `r`.`perm_ot_edit`, `r`.`perm_ot_delete`, `r`.`perm_ot_add_detalle`, `r`.`perm_ot_generar_reporte`, `r`.`perm_ot_add_herramienta`
             FROM user_system u
             LEFT JOIN empleado e
               ON e.id_empleado = u.id_empleado
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN roles_permisos r
               ON r.id = u.tipo
             WHERE u.username = :username
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> cargarUsuarioAuthPorIdEmpleado.
-- -----------------------------------------------------------------------------
SELECT
                `u`.`id_ai_user`, `u`.`id_empleado`, `u`.`username`, `u`.`password`, `u`.`failed_login_attempts`, `u`.`account_locked`, `u`.`locked_at`, `u`.`password_reset_required`, `u`.`last_login_at`, `u`.`last_login_ip`, `u`.`tipo`, `u`.`std_reg`,
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                e.correo,
                `r`.`id`, `r`.`nombre_rol`, `r`.`perm_usuarios_view`, `r`.`perm_usuarios_add`, `r`.`perm_usuarios_edit`, `r`.`perm_usuarios_delete`, `r`.`perm_herramienta_view`, `r`.`perm_herramienta_add`, `r`.`perm_herramienta_edit`, `r`.`perm_herramienta_delete`, `r`.`perm_miembro_view`, `r`.`perm_miembro_add`, `r`.`perm_miembro_edit`, `r`.`perm_miembro_delete`, `r`.`perm_ot_view`, `r`.`perm_ot_add`, `r`.`perm_ot_edit`, `r`.`perm_ot_delete`, `r`.`perm_ot_add_detalle`, `r`.`perm_ot_generar_reporte`, `r`.`perm_ot_add_herramienta`
             FROM user_system u
             LEFT JOIN empleado e
               ON e.id_empleado = u.id_empleado
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN roles_permisos r
               ON r.id = u.tipo
             WHERE u.id_empleado = :id_empleado
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> recuperarClaveControlador.
-- -----------------------------------------------------------------------------
SELECT
                    u.id_ai_user,
                    u.id_empleado,
                    u.username,
                    u.std_reg AS user_std_reg,
                    COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                    e.correo,
                    e.std_reg AS empleado_std_reg
                 FROM user_system u
                 LEFT JOIN empleado e
                   ON e.id_empleado = u.id_empleado
                 WHERE u.username = :username
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> iniciarSesionControlador.
-- -----------------------------------------------------------------------------
CALL sp_usuario_registrar_login_fallido(:username, :ip);

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> iniciarSesionControlador.
-- -----------------------------------------------------------------------------
CALL sp_usuario_registrar_login_exitoso(:id_empleado, :ip);

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: empleados / actualizar
-- documenta la operacion 'actualizar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT 1
                 FROM user_system
                 WHERE id_empleado = :id
                   AND std_reg = 1
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 13. Bloque de modulo: ordenes_trabajo / buscar
-- documenta la operacion 'buscar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalle.php.
-- -----------------------------------------------------------------------------
SELECT 1 FROM user_system WHERE id_empleado = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 14. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarComboTecControlador.
-- -----------------------------------------------------------------------------
SELECT
        u.id_empleado AS id_user,
        e.nombre_empleado AS user
      FROM user_system u
      INNER JOIN empleado e ON e.id_empleado = u.id_empleado
      WHERE u.std_reg = 1
        AND e.std_reg = 1
      ORDER BY e.nombre_empleado ASC;

-- -----------------------------------------------------------------------------
-- Bloque 15. Bloque de modulo: reportes / buscar
-- documenta la operacion 'buscar' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/cargarFiltrosReporte.php.
-- -----------------------------------------------------------------------------
SELECT
            id_empleado AS id_user,
            COALESCE(NULLIF(nombre_empleado, ''), id_empleado) AS user,
            username
         FROM vw_usuario_empleado
         WHERE std_reg = 1
         ORDER BY COALESCE(NULLIF(nombre_empleado, ''), id_empleado) ASC;

-- -----------------------------------------------------------------------------
-- Bloque 16. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> obtenerUsuarioPorId.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_user,
                id_empleado,
                username,
                password,
                tipo,
                std_reg
             FROM user_system
             WHERE id_empleado = :id
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 17. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> existeUsernameEnOtroUsuario.
-- -----------------------------------------------------------------------------
SELECT 1
                FROM user_system
                WHERE username = :username
AND id_empleado <> :exclude
LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 18. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> actualizarDatosUser.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system
             SET id_empleado = :idEmpleado,
                 username = :username,
                 tipo = :tipo
             WHERE id_empleado = :idActual;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 19. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> actualizarDatosUserSesion.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system SET username = :username
WHERE id_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 20. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> actualizarClaveUser.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system
             SET password = :password
             WHERE id_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 21. Bloque de modulo: usuarios / buscar
-- documenta la operacion 'buscar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/cargarDatosUser.php.
-- -----------------------------------------------------------------------------
SELECT
        u.id_ai_user,
        u.id_empleado AS id_user,
        u.username,
        u.tipo,
        u.std_reg,
        COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
        e.id_ai_categoria_empleado,
        COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria
     FROM user_system u
     LEFT JOIN empleado e
       ON e.id_empleado = u.id_empleado
     LEFT JOIN categoria_empleado c
       ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
     WHERE u.id_empleado = :id
     AND u.std_reg = 1
     LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 22. Bloque de modulo: usuarios / buscar
-- documenta la operacion 'buscar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorUser.php.
-- -----------------------------------------------------------------------------
SELECT
        id_ai_user,
        id_empleado AS id_user,
        COALESCE(NULLIF(nombre_empleado, ''), id_empleado) AS nombre_empleado,
        COALESCE(categoria_empleado, 'SIN CATEGORIA') AS nombre_categoria,
        username,
        id_rol AS tipo,
        nombre_rol
    FROM vw_usuario_empleado
    WHERE id_empleado <> :session_user
      AND std_reg = 1
AND (
            id_empleado LIKE :term_id
         OR COALESCE(NULLIF(nombre_empleado, ''), id_empleado) LIKE :term_nombre
         OR COALESCE(categoria_empleado, '') LIKE :term_categoria
         OR username LIKE :term_username
         OR nombre_rol LIKE :term_rol
      )
ORDER BY COALESCE(NULLIF(nombre_empleado, ''), id_empleado) ASC;

-- -----------------------------------------------------------------------------
-- Bloque 23. Bloque de modulo: usuarios / crear
-- documenta la operacion 'crear' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> registrarUserControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system
                 SET username = :username,
                     password = :password,
                     tipo = :tipo,
                     std_reg = 1
                 WHERE id_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 24. Bloque de modulo: usuarios / crear
-- documenta la operacion 'crear' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> registrarUserControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO user_system (id_empleado, username, password, tipo, std_reg)
                 VALUES (:id, :username, :password, :tipo, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 25. Bloque de modulo: usuarios / eliminar
-- documenta la operacion 'eliminar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> eliminarUserControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE user_system
             SET std_reg = 0
             WHERE id_empleado = :id
               AND id_empleado <> :sessionUser;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 26. Bloque de modulo: usuarios / listar
-- documenta la operacion 'listar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> listarUsuarioControlador.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_user,
                id_empleado AS id_user,
                username,
                id_rol AS tipo,
                COALESCE(NULLIF(nombre_empleado, ''), id_empleado) AS nombre_empleado,
                COALESCE(categoria_empleado, 'SIN CATEGORIA') AS nombre_categoria,
                nombre_rol
             FROM vw_usuario_empleado
             WHERE id_empleado <> :sessionId
               AND std_reg = 1
             ORDER BY COALESCE(NULLIF(nombre_empleado, ''), id_empleado) ASC;

