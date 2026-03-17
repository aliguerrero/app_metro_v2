CREATE TABLE IF NOT EXISTS reporte_generado (
    id_ai_reporte_generado INT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo_reporte VARCHAR(50) NOT NULL,
    titulo_reporte VARCHAR(150) NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf',
    tamano_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
    parametros_json LONGTEXT NULL,
    id_user_generador VARCHAR(30) NOT NULL,
    nombre_user_generador VARCHAR(150) NOT NULL,
    username_generador VARCHAR(60) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    std_reg TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_ai_reporte_generado),
    KEY idx_reporte_generado_fecha (created_at),
    KEY idx_reporte_generado_tipo (tipo_reporte),
    KEY idx_reporte_generado_user (id_user_generador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
