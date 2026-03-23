USE bdapp_metro;

SET @app_user := '22206460';

-- Desactivar temporalmente protecciones de borrado fisico
DROP TRIGGER IF EXISTS trg_orden_trabajo_bd;
DROP TRIGGER IF EXISTS trg_reporte_generado_bd;
DROP TRIGGER IF EXISTS trg_miembro_bd;
DROP TRIGGER IF EXISTS trg_herramienta_bd;
DROP TRIGGER IF EXISTS trg_empleado_bd;
DROP TRIGGER IF EXISTS trg_area_trabajo_bd;
DROP TRIGGER IF EXISTS trg_sitio_trabajo_bd;
DROP TRIGGER IF EXISTS trg_turno_trabajo_bd;
DROP TRIGGER IF EXISTS trg_estado_ot_bd;
DROP TRIGGER IF EXISTS trg_log_user_no_delete;

-- Limpieza de datos transaccionales
DELETE FROM detalle_orden;
ALTER TABLE detalle_orden AUTO_INCREMENT = 1;

DELETE FROM herramientaot;
ALTER TABLE herramientaot AUTO_INCREMENT = 1;

DELETE FROM orden_trabajo;
ALTER TABLE orden_trabajo AUTO_INCREMENT = 1;

DELETE FROM reporte_generado;
ALTER TABLE reporte_generado AUTO_INCREMENT = 1;

DELETE FROM miembro;
ALTER TABLE miembro AUTO_INCREMENT = 1;

DELETE FROM herramienta;
ALTER TABLE herramienta AUTO_INCREMENT = 1;

-- Conserva empleados con usuario del sistema y elimina temporales o de prueba
DELETE e
FROM empleado e
LEFT JOIN user_system us
  ON us.id_empleado = e.id_empleado
WHERE us.id_empleado IS NULL;

ALTER TABLE empleado AUTO_INCREMENT = 4;

DELETE FROM area_trabajo WHERE std_reg = 0;
DELETE FROM sitio_trabajo WHERE std_reg = 0;
DELETE FROM turno_trabajo WHERE std_reg = 0;
DELETE FROM estado_ot WHERE std_reg = 0;

CREATE TRIGGER trg_orden_trabajo_bd
BEFORE DELETE ON orden_trabajo
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en orden_trabajo. Use eliminacion logica (UPDATE orden_trabajo SET std_reg=0 ...).';

CREATE TRIGGER trg_reporte_generado_bd
BEFORE DELETE ON reporte_generado
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).';

CREATE TRIGGER trg_miembro_bd
BEFORE DELETE ON miembro
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en miembro. Use eliminacion logica (UPDATE miembro SET std_reg=0 ...).';

CREATE TRIGGER trg_herramienta_bd
BEFORE DELETE ON herramienta
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en herramienta. Use eliminacion logica (UPDATE herramienta SET std_reg=0 ...).';

CREATE TRIGGER trg_empleado_bd
BEFORE DELETE ON empleado
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).';

CREATE TRIGGER trg_area_trabajo_bd
BEFORE DELETE ON area_trabajo
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en area_trabajo. Use eliminacion logica (UPDATE area_trabajo SET std_reg=0 ...).';

CREATE TRIGGER trg_sitio_trabajo_bd
BEFORE DELETE ON sitio_trabajo
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en sitio_trabajo. Use eliminacion logica (UPDATE sitio_trabajo SET std_reg=0 ...).';

CREATE TRIGGER trg_turno_trabajo_bd
BEFORE DELETE ON turno_trabajo
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en turno_trabajo. Use eliminacion logica (UPDATE turno_trabajo SET std_reg=0 ...).';

CREATE TRIGGER trg_estado_ot_bd
BEFORE DELETE ON estado_ot
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en estado_ot. Use eliminacion logica (UPDATE estado_ot SET std_reg=0 ...).';

-- Areas de trabajo
UPDATE area_trabajo
   SET nombre_area = 'SENALIZACION',
       nomeclatura = 'VF-SEN-',
       std_reg = 1
 WHERE id_ai_area = 1;

UPDATE area_trabajo
   SET nombre_area = 'APARATO DE VIA',
       nomeclatura = 'VF-APV-',
       std_reg = 1
 WHERE id_ai_area = 2;

UPDATE area_trabajo
   SET nombre_area = 'INFRAESTRUCTURA',
       nomeclatura = 'VF-INF-',
       std_reg = 1
 WHERE id_ai_area = 3;

UPDATE area_trabajo
   SET nombre_area = 'NO PROGRAMADA',
       nomeclatura = 'VF-NP-',
       std_reg = 1
 WHERE id_ai_area = 5;

ALTER TABLE area_trabajo AUTO_INCREMENT = 6;

-- Sitios de trabajo
UPDATE sitio_trabajo
   SET nombre_sitio = 'PATIO OPERACIONAL',
       std_reg = 1
 WHERE id_ai_sitio = 1;

UPDATE sitio_trabajo
   SET nombre_sitio = 'LINEA 1',
       std_reg = 1
 WHERE id_ai_sitio = 2;

INSERT INTO sitio_trabajo (id_ai_sitio, nombre_sitio, std_reg) VALUES
(3, 'TALLER CENTRAL', 1),
(4, 'SUBESTACION SUR', 1),
(5, 'ESTACION CEDENO', 1)
ON DUPLICATE KEY UPDATE
  nombre_sitio = VALUES(nombre_sitio),
  std_reg = VALUES(std_reg);

ALTER TABLE sitio_trabajo AUTO_INCREMENT = 6;

-- Turnos de trabajo
UPDATE turno_trabajo SET nombre_turno = 'MANANA', std_reg = 1 WHERE id_ai_turno = 1;
UPDATE turno_trabajo SET nombre_turno = 'TARDE', std_reg = 1 WHERE id_ai_turno = 2;
UPDATE turno_trabajo SET nombre_turno = 'NOCHE', std_reg = 1 WHERE id_ai_turno = 3;
UPDATE turno_trabajo SET nombre_turno = 'MADRUGADA', std_reg = 1 WHERE id_ai_turno = 4;

ALTER TABLE turno_trabajo AUTO_INCREMENT = 5;

-- Estados de O.T.
UPDATE estado_ot
   SET nombre_estado = 'NO EJECUTADA',
       color = '#dc3545',
       libera_herramientas = 0,
       bloquea_ot = 0,
       std_reg = 1
 WHERE id_ai_estado = 2;

UPDATE estado_ot
   SET nombre_estado = 'RE-PROGRAMADA',
       color = '#0d6efd',
       libera_herramientas = 0,
       bloquea_ot = 0,
       std_reg = 1
 WHERE id_ai_estado = 3;

UPDATE estado_ot
   SET nombre_estado = 'SUSPENDIDA',
       color = '#fd7e14',
       libera_herramientas = 0,
       bloquea_ot = 0,
       std_reg = 1
 WHERE id_ai_estado = 4;

UPDATE estado_ot
   SET nombre_estado = 'EN EJECUCION',
       color = '#ffc107',
       libera_herramientas = 0,
       bloquea_ot = 0,
       std_reg = 1
 WHERE id_ai_estado = 12;

ALTER TABLE estado_ot AUTO_INCREMENT = 13;

-- Categorias de empleado
INSERT INTO categoria_empleado (id_ai_categoria_empleado, nombre_categoria, descripcion, std_reg) VALUES
(1, 'COORDINACION OPERATIVA', 'Personal responsable de la coordinacion general y seguimiento de mantenimiento.', 1),
(2, 'SUPERVISION DE MANTENIMIENTO', 'Supervisores responsables de planificar y validar la ejecucion de trabajos.', 1),
(3, 'TECNICO DE MANTENIMIENTO', 'Tecnicos que ejecutan actividades de campo y atienden incidencias operativas.', 1),
(4, 'OPERADOR CCF', 'Personal de apoyo operativo asignado al Centro de Control de Fallas.', 1),
(5, 'OPERADOR CCO', 'Personal de apoyo operativo asignado al Centro de Control de Operaciones.', 1)
ON DUPLICATE KEY UPDATE
  nombre_categoria = VALUES(nombre_categoria),
  descripcion = VALUES(descripcion),
  std_reg = VALUES(std_reg);

ALTER TABLE categoria_empleado AUTO_INCREMENT = 6;

-- Categorias de herramienta
INSERT INTO categoria_herramienta (id_ai_categoria_herramienta, nombre_categoria, descripcion, std_reg) VALUES
(1, 'HERRAMIENTAS MANUALES', 'Herramientas de uso mecanico y de ajuste general en campo.', 1),
(2, 'MEDICION Y DIAGNOSTICO', 'Instrumentos para medicion electrica, continuidad y verificacion tecnica.', 1),
(3, 'EQUIPOS ELECTRICOS', 'Equipos electricos portatiles para perforacion, corte y apoyo operativo.', 1),
(4, 'SEGURIDAD INDUSTRIAL', 'Dotacion de proteccion personal y apoyo para trabajo seguro.', 1),
(5, 'SOLDADURA Y CORTE', 'Equipos para soldadura, corte y adecuacion metalmecanica.', 1)
ON DUPLICATE KEY UPDATE
  nombre_categoria = VALUES(nombre_categoria),
  descripcion = VALUES(descripcion),
  std_reg = VALUES(std_reg);

ALTER TABLE categoria_herramienta AUTO_INCREMENT = 6;

-- Reasignacion de categorias a usuarios existentes
UPDATE empleado
   SET telefono = '0412-8251111',
       id_ai_categoria_empleado = 1
 WHERE id_empleado = '22206460';

UPDATE empleado
   SET id_ai_categoria_empleado = 2
 WHERE id_empleado = '8840285';

UPDATE empleado
   SET id_ai_categoria_empleado = 3
 WHERE id_empleado = '26580187';

-- Empleados nuevos para miembros de presentacion
INSERT INTO empleado (
    id_empleado,
    nacionalidad,
    nombre_empleado,
    telefono,
    direccion,
    correo,
    id_ai_categoria_empleado,
    std_reg
) VALUES
('30114567', 'V', 'CARLA MENDOZA', '0412-5184401', 'SAN BLAS - VALENCIA', 'carla.mendoza@metrovalencia.local', 4, 1),
('29654781', 'V', 'JOSE PENA', '0414-6883210', 'PARQUE VALENCIA - VALENCIA', 'jose.pena@metrovalencia.local', 5, 1),
('31890245', 'V', 'LUIS RAMIREZ', '0412-5441188', 'FLOR AMARILLO - VALENCIA', 'luis.ramirez@metrovalencia.local', 4, 1),
('28765431', 'V', 'MARIA FERNANDEZ', '0424-6013359', 'LA ISABELICA - VALENCIA', 'maria.fernandez@metrovalencia.local', 5, 1),
('27411890', 'V', 'ANDRES PEREZ', '0414-6092271', 'SANTA ROSA - VALENCIA', 'andres.perez@metrovalencia.local', 4, 1),
('29987456', 'V', 'DIANA RODRIGUEZ', '0412-7712240', 'LA CANDELARIA - VALENCIA', 'diana.rodriguez@metrovalencia.local', 5, 1),
('31244780', 'V', 'OSCAR SALAZAR', '0424-7731180', 'LOS COLORADOS - VALENCIA', 'oscar.salazar@metrovalencia.local', 4, 1),
('30599871', 'V', 'ELIANA TORRES', '0414-5513072', 'NAGUANAGUA - CARABOBO', 'eliana.torres@metrovalencia.local', 5, 1)
ON DUPLICATE KEY UPDATE
  nacionalidad = VALUES(nacionalidad),
  nombre_empleado = VALUES(nombre_empleado),
  telefono = VALUES(telefono),
  direccion = VALUES(direccion),
  correo = VALUES(correo),
  id_ai_categoria_empleado = VALUES(id_ai_categoria_empleado),
  std_reg = VALUES(std_reg);

-- Miembros nuevos vinculados a empleados que no son usuarios del sistema
INSERT INTO miembro (id_miembro, id_empleado, nombre_miembro, tipo_miembro, std_reg) VALUES
('M-001', '30114567', 'CARLA MENDOZA', 1, 1),
('M-002', '29654781', 'JOSE PENA', 2, 1),
('M-003', '31890245', 'LUIS RAMIREZ', 1, 1),
('M-004', '28765431', 'MARIA FERNANDEZ', 2, 1),
('M-005', '27411890', 'ANDRES PEREZ', 1, 1),
('M-006', '29987456', 'DIANA RODRIGUEZ', 2, 1),
('M-007', '31244780', 'OSCAR SALAZAR', 1, 1),
('M-008', '30599871', 'ELIANA TORRES', 2, 1);

-- Herramientas para la presentacion
INSERT INTO herramienta (nombre_herramienta, id_ai_categoria_herramienta, cantidad, estado, std_reg) VALUES
('Martillo de via', 1, 6, '1', 1),
('Llave de impacto 3/4', 1, 4, '1', 1),
('Juego de destornilladores aislados', 1, 8, '1', 1),
('Pinza amperimetrica', 2, 3, '1', 1),
('Multimetro digital', 2, 4, '1', 1),
('Medidor laser de distancia', 2, 2, '2', 1),
('Taladro percutor industrial', 3, 5, '1', 1),
('Amoladora angular 7in', 3, 3, '2', 1),
('Generador portatil 5kVA', 3, 2, '1', 1),
('Casco de seguridad', 4, 20, '1', 1),
('Arnes de seguridad', 4, 10, '1', 1),
('Guantes dielectricos', 4, 15, '1', 1),
('Soldadora inverter', 5, 2, '1', 1),
('Careta de soldar', 5, 4, '1', 1),
('Cizalla para cables', 5, 3, '2', 1),
('Escalera telescopica', 4, 4, '1', 1);

-- Ordenes de trabajo para la presentacion
CALL sp_ot_crear(
  'VF-SEN-001', 1, '8840285', 2, 2,
  'INSPECCION Y AJUSTE DE BALIZAS EN TRAMO SUR',
  '2026-03-16', WEEK('2026-03-16', 1), MONTH('2026-03-16')
);

CALL sp_ot_crear(
  'VF-SEN-002', 1, '26580187', 5, 12,
  'CALIBRACION DE CIRCUITO DE ANUNCIO EN ESTACION CEDENO',
  '2026-03-17', WEEK('2026-03-17', 1), MONTH('2026-03-17')
);

CALL sp_ot_crear(
  'VF-APV-001', 2, '8840285', 1, 2,
  'LUBRICACION Y AJUSTE DE CAMBIO 04 EN PATIO OPERACIONAL',
  '2026-03-18', WEEK('2026-03-18', 1), MONTH('2026-03-18')
);

CALL sp_ot_crear(
  'VF-APV-002', 2, '26580187', 3, 2,
  'SUSTITUCION PROGRAMADA DE PERNOS EN DESVIO NORTE',
  '2026-03-19', WEEK('2026-03-19', 1), MONTH('2026-03-19')
);

CALL sp_ot_crear(
  'VF-INF-001', 3, '8840285', 4, 2,
  'CORRECCION DE FILTRACION EN CANALETA TECNICA',
  '2026-03-20', WEEK('2026-03-20', 1), MONTH('2026-03-20')
);

CALL sp_ot_crear(
  'VF-INF-002', 3, '26580187', 2, 2,
  'RESANE DE BORDE Y REPOSICION DE TAPAS DE REGISTRO EN ANDEN',
  '2026-03-21', WEEK('2026-03-21', 1), MONTH('2026-03-21')
);

CALL sp_ot_crear(
  'VF-NP-001', 5, '8840285', 1, 2,
  'ATENCION DE FALLA EN TOMA DE ENERGIA DE TALLER LIGERO',
  '2026-03-21', WEEK('2026-03-21', 1), MONTH('2026-03-21')
);

CALL sp_ot_crear(
  'VF-NP-002', 5, '26580187', 2, 2,
  'REVISION DE GABINETE DE COMUNICACIONES POR ALARMA INTERMITENTE',
  '2026-03-22', WEEK('2026-03-22', 1), MONTH('2026-03-22')
);

-- Detalles de orden
CALL sp_ot_agregar_detalle(
  'VF-SEN-001', '2026-03-16',
  'Revision de conexionado, limpieza de borneras y ajuste de tres balizas de via en tramo sur.',
  1, 'M-002', '8840285', 'M-001', 3, '07:30:00', '10:30:00',
  'Trabajo coordinado con ventana de mantenimiento.'
);

CALL sp_ot_agregar_detalle(
  'VF-SEN-002', '2026-03-17',
  'Prueba funcional del circuito de anuncio, verificacion de tarjetas y recalibracion de tiempos de enclavamiento.',
  2, 'M-004', '26580187', 'M-003', 2, '13:00:00', '16:30:00',
  'OT en seguimiento por pruebas operativas.'
);

CALL sp_ot_agregar_detalle(
  'VF-APV-001', '2026-03-18',
  'Lubricacion de agujas, torque de fijaciones y verificacion de desplazamiento del cambio 04.',
  1, 'M-006', '8840285', 'M-005', 4, '08:00:00', '11:30:00',
  'Actividad completada sin novedades.'
);

CALL sp_ot_agregar_detalle(
  'VF-APV-002', '2026-03-19',
  'Desmontaje parcial para reemplazo de pernos de sujecion; pendiente ingreso de repuesto.',
  3, 'M-008', '26580187', 'M-007', 3, '20:00:00', '23:30:00',
  'Reprogramada por falta de pernos calibre 7/8.'
);

CALL sp_ot_agregar_detalle(
  'VF-INF-001', '2026-03-20',
  'Limpieza de drenaje, picado de zona afectada y resane con mortero de alta adherencia.',
  1, 'M-002', '8840285', 'M-005', 3, '08:30:00', '12:00:00',
  'Pendiente suministro de mortero epoxico.'
);

CALL sp_ot_agregar_detalle(
  'VF-INF-002', '2026-03-21',
  'Reposicion de tapas, nivelacion de soporte y reparacion puntual de borde de anden.',
  2, 'M-004', '26580187', 'M-007', 2, '14:00:00', '17:00:00',
  'Se ejecuto conforme al plan de mantenimiento.'
);

CALL sp_ot_agregar_detalle(
  'VF-NP-001', '2026-03-21',
  'Inspeccion de toma energizada y prueba de continuidad; se suspende por aislador fisurado.',
  4, 'M-006', '8840285', 'M-003', 2, '05:30:00', '07:00:00',
  'Suspension preventiva por componente aislante danado.'
);

CALL sp_ot_agregar_detalle(
  'VF-NP-002', '2026-03-22',
  'Revision inicial del gabinete, lectura de alarmas y verificacion de voltajes en fuente secundaria.',
  2, 'M-008', '26580187', 'M-001', 2, '13:30:00', '15:30:00',
  'A la espera de ventana nocturna para intervencion.'
);

-- Asignacion de herramientas
CALL sp_ot_asignar_herramienta('VF-SEN-001', 4, 1, '8840285');
CALL sp_ot_asignar_herramienta('VF-SEN-001', 5, 1, '8840285');
CALL sp_ot_asignar_herramienta('VF-SEN-001', 10, 3, '8840285');

CALL sp_ot_asignar_herramienta('VF-SEN-002', 7, 1, '26580187');
CALL sp_ot_asignar_herramienta('VF-SEN-002', 10, 2, '26580187');
CALL sp_ot_asignar_herramienta('VF-SEN-002', 11, 1, '26580187');

CALL sp_ot_asignar_herramienta('VF-APV-001', 1, 2, '8840285');
CALL sp_ot_asignar_herramienta('VF-APV-001', 2, 1, '8840285');
CALL sp_ot_asignar_herramienta('VF-APV-001', 10, 4, '8840285');

CALL sp_ot_asignar_herramienta('VF-INF-001', 10, 3, '8840285');
CALL sp_ot_asignar_herramienta('VF-INF-001', 16, 1, '8840285');

CALL sp_ot_asignar_herramienta('VF-INF-002', 6, 1, '26580187');
CALL sp_ot_asignar_herramienta('VF-INF-002', 7, 1, '26580187');
CALL sp_ot_asignar_herramienta('VF-INF-002', 10, 2, '26580187');

CALL sp_ot_asignar_herramienta('VF-NP-002', 4, 1, '26580187');
CALL sp_ot_asignar_herramienta('VF-NP-002', 5, 1, '26580187');

-- Cambios de estado finales
CALL sp_ot_cambiar_estado('VF-APV-001', 1, '8840285');
CALL sp_ot_cambiar_estado('VF-APV-002', 3, '26580187');
CALL sp_ot_cambiar_estado('VF-INF-002', 1, '26580187');
CALL sp_ot_cambiar_estado('VF-NP-001', 4, '8840285');

-- Reinicio de autoincrementables para una numeracion limpia
ALTER TABLE miembro AUTO_INCREMENT = 9;
ALTER TABLE herramienta AUTO_INCREMENT = 17;
ALTER TABLE orden_trabajo AUTO_INCREMENT = 9;
ALTER TABLE detalle_orden AUTO_INCREMENT = 9;
ALTER TABLE herramientaot AUTO_INCREMENT = 17;

-- Auditoria y reportes en blanco para la demo
DELETE FROM log_user;
ALTER TABLE log_user AUTO_INCREMENT = 1;

CREATE TRIGGER trg_log_user_no_delete
BEFORE DELETE ON log_user
FOR EACH ROW
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoria (log_user).';
