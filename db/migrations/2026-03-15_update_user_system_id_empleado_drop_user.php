<?php
declare(strict_types=1);

require __DIR__ . '/../../config/server.php';

const MIGRATION_ROOT_DEFINER = 'root@localhost';

function migration_log(string $type, string $message): void
{
    echo '[' . strtoupper($type) . '] ' . $message . PHP_EOL;
}

function migration_exec(PDO $pdo, string $sql, string $label): void
{
    $pdo->exec($sql);
    migration_log('ok', $label);
}

function migration_exec_trigger(PDO $pdo, string $sql, string $label, ?PDO $rootPdo = null): void
{
    if ($rootPdo instanceof PDO) {
        $rootPdo->exec($sql);
        migration_log('ok', $label . ' (creado con root@localhost)');
        return;
    }

    try {
        $pdo->exec($sql);
        migration_log('ok', $label);
    } catch (PDOException $e) {
        $needsFallback = str_contains($e->getMessage(), 'SUPER privilege')
            || str_contains($e->getMessage(), '1227');

        if (!$needsFallback) {
            throw $e;
        }

        $fallbackSql = preg_replace(
            '/^CREATE\s+DEFINER\s*=\s*`?[^`@ ]+`?@`?[^` ]+`?\s+TRIGGER\s+/i',
            'CREATE TRIGGER ',
            $sql,
            1
        );

        if (!is_string($fallbackSql) || trim($fallbackSql) === trim($sql)) {
            throw $e;
        }

        $pdo->exec($fallbackSql);
        migration_log('ok', $label . ' (fallback sin DEFINER explicito)');
    }
}

function migration_exists_column(PDO $pdo, string $schema, string $table, string $column): bool
{
    $stmt = $pdo->prepare(
        "SELECT COUNT(1)
         FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = :schema
           AND TABLE_NAME = :table
           AND COLUMN_NAME = :column"
    );
    $stmt->execute([
        ':schema' => $schema,
        ':table' => $table,
        ':column' => $column,
    ]);

    return (int)$stmt->fetchColumn() > 0;
}

function migration_exists_constraint(PDO $pdo, string $schema, string $table, string $constraint): bool
{
    $stmt = $pdo->prepare(
        "SELECT COUNT(1)
         FROM information_schema.TABLE_CONSTRAINTS
         WHERE CONSTRAINT_SCHEMA = :schema
           AND TABLE_NAME = :table
           AND CONSTRAINT_NAME = :constraint"
    );
    $stmt->execute([
        ':schema' => $schema,
        ':table' => $table,
        ':constraint' => $constraint,
    ]);

    return (int)$stmt->fetchColumn() > 0;
}

function migration_exists_trigger(PDO $pdo, string $schema, string $trigger): bool
{
    $stmt = $pdo->prepare(
        "SELECT COUNT(1)
         FROM information_schema.TRIGGERS
         WHERE TRIGGER_SCHEMA = :schema
           AND TRIGGER_NAME = :trigger"
    );
    $stmt->execute([
        ':schema' => $schema,
        ':trigger' => $trigger,
    ]);

    return (int)$stmt->fetchColumn() > 0;
}

function migration_find_unique_index_by_column(PDO $pdo, string $schema, string $table, string $column): ?string
{
    $stmt = $pdo->prepare(
        "SELECT INDEX_NAME
         FROM information_schema.STATISTICS
         WHERE TABLE_SCHEMA = :schema
           AND TABLE_NAME = :table
           AND COLUMN_NAME = :column
           AND NON_UNIQUE = 0
         ORDER BY INDEX_NAME ASC
         LIMIT 1"
    );
    $stmt->execute([
        ':schema' => $schema,
        ':table' => $table,
        ':column' => $column,
    ]);

    $index = $stmt->fetchColumn();
    return is_string($index) && $index !== '' ? $index : null;
}

function migration_exists_index(PDO $pdo, string $schema, string $table, string $index): bool
{
    $stmt = $pdo->prepare(
        "SELECT COUNT(1)
         FROM information_schema.STATISTICS
         WHERE TABLE_SCHEMA = :schema
           AND TABLE_NAME = :table
           AND INDEX_NAME = :index"
    );
    $stmt->execute([
        ':schema' => $schema,
        ':table' => $table,
        ':index' => $index,
    ]);

    return (int)$stmt->fetchColumn() > 0;
}

function migration_quote_identifier(string $identifier): string
{
    return '`' . str_replace('`', '``', $identifier) . '`';
}

function migration_get_create_trigger(PDO $pdo, string $trigger): string
{
    $stmt = $pdo->query('SHOW CREATE TRIGGER ' . migration_quote_identifier($trigger));
    $row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

    if (!is_array($row)) {
        throw new RuntimeException("No se pudo leer el trigger {$trigger}.");
    }

    foreach ($row as $value) {
        if (is_string($value) && strncmp(ltrim($value), 'CREATE ', 7) === 0) {
            return str_replace("\r\n", "\n", $value);
        }
    }

    throw new RuntimeException("No se encontro la definicion CREATE del trigger {$trigger}.");
}

function migration_normalize_actor_lookup(string $sql): string
{
    $search = "(SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1)";
    $replace = "(SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1)";

    return str_replace($search, $replace, $sql);
}

function migration_load_trigger_definitions_from_docs(): array
{
    $baseDir = realpath(__DIR__ . '/../../docs/scripts app_metro/triggers');
    if ($baseDir === false) {
        throw new RuntimeException('No se encontro la carpeta de documentacion de triggers.');
    }

    $files = glob($baseDir . '/*/scripts.txt');
    if ($files === false || $files === []) {
        throw new RuntimeException('No se encontraron scripts documentados de triggers.');
    }

    $definitions = [];

    foreach ($files as $file) {
        $content = file_get_contents($file);
        if (!is_string($content) || trim($content) === '') {
            continue;
        }

        $content = str_replace("\r\n", "\n", $content);
        preg_match_all(
            '/CREATE DEFINER=root@localhost TRIGGER\s+[a-zA-Z0-9_]+[\s\S]*?(?=\n\n- trg_|\z)/',
            $content,
            $matches
        );

        foreach ($matches[0] as $sql) {
            $sql = trim($sql);
            if (!preg_match('/CREATE DEFINER=root@localhost TRIGGER\s+([a-zA-Z0-9_]+)/', $sql, $nameMatch)) {
                continue;
            }

            $triggerName = $nameMatch[1];
            $definitions[$triggerName] = migration_normalize_actor_lookup($sql);
        }
    }

    return $definitions;
}

function migration_build_user_system_triggers(): array
{
    return [
        'trg_user_system_ai' => <<<'SQL'
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW
INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  'INSERT',
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CONCAT('CREAR ', 'user_system'),
  CONCAT('INSERT user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)),
  NULL,
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  'id_ai_user,id_empleado,username,password,tipo,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
SQL,
        'trg_user_system_au' => <<<'SQL'
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW
INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'user_system') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'user_system') ELSE CONCAT('MODIFICAR ', 'user_system') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) ELSE CONCAT('UPDATE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) END,
  JSON_OBJECT('id_ai_user', OLD.`id_ai_user`, 'id_empleado', OLD.`id_empleado`, 'username', OLD.`username`, 'password', '***', 'tipo', OLD.`tipo`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), JSON_OBJECT('id_ai_user', JSON_ARRAY(OLD.`id_ai_user`, NEW.`id_ai_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), JSON_OBJECT('id_empleado', JSON_ARRAY(OLD.`id_empleado`, NEW.`id_empleado`)), JSON_OBJECT())), IF(NOT (OLD.`username` <=> NEW.`username`), JSON_OBJECT('username', JSON_ARRAY(OLD.`username`, NEW.`username`)), JSON_OBJECT())), IF(NOT (OLD.`password` <=> NEW.`password`), JSON_OBJECT('password', 'CHANGED'), JSON_OBJECT())), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), JSON_OBJECT('tipo', JSON_ARRAY(OLD.`tipo`, NEW.`tipo`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), 'id_ai_user', NULL), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL), IF(NOT (OLD.`username` <=> NEW.`username`), 'username', NULL), IF(NOT (OLD.`password` <=> NEW.`password`), 'password', NULL), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), 'tipo', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
SQL,
        'trg_user_system_bd' => <<<'SQL'
CREATE DEFINER=`root`@`localhost` TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en user_system. Use eliminacion logica (UPDATE user_system SET std_reg=0 ...).'
SQL,
    ];
}

$dsn = 'mysql:host=' . DB_SERVER . ';dbname=' . DB_NAME . ';charset=utf8mb4';
$pdo = new PDO($dsn, DB_AUTH_USER, DB_AUTH_PASS, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
]);
$rootPdo = null;

try {
    $rootPdo = new PDO($dsn, 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    migration_log('info', 'Conexion root@localhost disponible para recrear triggers con definer correcto.');
} catch (Throwable $e) {
    migration_log('info', 'No fue posible abrir conexion root local. Se usara la cuenta administrativa configurada.');
}

$schema = DB_NAME;
migration_log('info', 'Analizando triggers y esquema actual...');

$triggersToRebuild = migration_load_trigger_definitions_from_docs();

foreach (migration_build_user_system_triggers() as $triggerName => $triggerSql) {
    $triggersToRebuild[$triggerName] = $triggerSql;
}

foreach (array_keys($triggersToRebuild) as $triggerName) {
    if (migration_exists_trigger($pdo, $schema, $triggerName)) {
        migration_exec($pdo, 'DROP TRIGGER IF EXISTS ' . migration_quote_identifier($triggerName), "Trigger {$triggerName} eliminado");
    }
}

$constraintsToDrop = [
    ['table' => 'detalle_orden', 'constraint' => 'detalle_orden_ibfk_2'],
    ['table' => 'orden_trabajo', 'constraint' => 'orden_trabajo_ibfk_1'],
    ['table' => 'log_user', 'constraint' => 'fk_log_user_user'],
    ['table' => 'user_system', 'constraint' => 'fk_user_system_empleado'],
];

foreach ($constraintsToDrop as $item) {
    if (migration_exists_constraint($pdo, $schema, $item['table'], $item['constraint'])) {
        migration_exec(
            $pdo,
            'ALTER TABLE ' . migration_quote_identifier($item['table']) . ' DROP FOREIGN KEY ' . migration_quote_identifier($item['constraint']),
            "FK {$item['constraint']} eliminada"
        );
    }
}

if (migration_exists_column($pdo, $schema, 'user_system', 'id_user')) {
    migration_exec(
        $pdo,
        "ALTER TABLE `user_system`
         CHANGE COLUMN `id_user` `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador del empleado asociado al usuario del sistema'",
        'Columna user_system.id_user renombrada a id_empleado'
    );
}

if (migration_exists_column($pdo, $schema, 'user_system', 'user')) {
    migration_exec(
        $pdo,
        "ALTER TABLE `user_system` DROP COLUMN `user`",
        'Columna user_system.user eliminada'
    );
}

if (migration_exists_column($pdo, $schema, 'user_system', 'id_empleado')) {
    migration_exec(
        $pdo,
        "ALTER TABLE `user_system`
         MODIFY COLUMN `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador del empleado asociado al usuario del sistema'",
        'Comentario de user_system.id_empleado actualizado'
    );
}

$uniqueIndex = migration_find_unique_index_by_column($pdo, $schema, 'user_system', 'id_empleado');
if ($uniqueIndex !== null && $uniqueIndex !== 'uk_user_system_id_empleado') {
    migration_exec(
        $pdo,
        'ALTER TABLE `user_system` DROP INDEX ' . migration_quote_identifier($uniqueIndex),
        "Indice unico legado {$uniqueIndex} eliminado"
    );
    $uniqueIndex = null;
}

if ($uniqueIndex === null && !migration_exists_index($pdo, $schema, 'user_system', 'uk_user_system_id_empleado')) {
    migration_exec(
        $pdo,
        'ALTER TABLE `user_system` ADD UNIQUE KEY `uk_user_system_id_empleado` (`id_empleado`)',
        'Indice unico uk_user_system_id_empleado creado'
    );
}

$constraintsToCreate = [
    "ALTER TABLE `user_system`
     ADD CONSTRAINT `fk_user_system_empleado`
     FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE",
    "ALTER TABLE `detalle_orden`
     ADD CONSTRAINT `detalle_orden_ibfk_2`
     FOREIGN KEY (`id_user_act`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE",
    "ALTER TABLE `orden_trabajo`
     ADD CONSTRAINT `orden_trabajo_ibfk_1`
     FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE",
    "ALTER TABLE `log_user`
     ADD CONSTRAINT `fk_log_user_user`
     FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE",
];

foreach ($constraintsToCreate as $sql) {
    $label = strtok(preg_replace('/\s+/', ' ', trim($sql)), "\n");
    try {
        migration_exec($pdo, $sql, $label);
    } catch (Throwable $e) {
        if (str_contains($e->getMessage(), 'Duplicate') || str_contains($e->getMessage(), 'already exists')) {
            migration_log('info', 'FK ya existente, se continua sin error: ' . $e->getMessage());
            continue;
        }
        throw $e;
    }
}

foreach ($triggersToRebuild as $triggerName => $triggerSql) {
    if ($triggerSql === null || trim($triggerSql) === '') {
        continue;
    }
    migration_exec_trigger($pdo, $triggerSql, "Trigger {$triggerName} recreado", $rootPdo);
}

$checks = [
    'tiene_id_empleado' => migration_exists_column($pdo, $schema, 'user_system', 'id_empleado'),
    'user_eliminado' => !migration_exists_column($pdo, $schema, 'user_system', 'user'),
    'fk_empleado' => migration_exists_constraint($pdo, $schema, 'user_system', 'fk_user_system_empleado'),
    'trigger_ai' => migration_exists_trigger($pdo, $schema, 'trg_user_system_ai'),
    'trigger_au' => migration_exists_trigger($pdo, $schema, 'trg_user_system_au'),
    'trigger_bd' => migration_exists_trigger($pdo, $schema, 'trg_user_system_bd'),
];

migration_log('info', 'Verificacion final: ' . json_encode($checks, JSON_UNESCAPED_UNICODE));
