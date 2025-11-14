# 🏥 **PROYECTO: SISTEMA DE GESTIÓN HOSPITALARIA**  
**Equipo:** Brad, Brigitte, Emmy  

## 📋 **DIVISIÓN DE TAREAS Y ROLES**

### **👨‍💼 BRAD - Líder de Proyecto / Base de Datos y Normalización**
**Responsabilidades:**
- Diseño del modelo de base de datos
- Normalización hasta 3FN
- Claves primarias y foráneas
- Documentación de estándares SQL

### **👩‍💼 BRIGITTE - Especialista en Estándares SQL/Calidad**
**Responsabilidades:**
- Aplicación de estándares SQL:2016
- Restricciones de integridad
- Validaciones y CHECK constraints
- Control de calidad del código

### **👩‍⚕️ EMMY - Desarrolladora de Funcionalidades**
**Responsabilidades:**
- Vistas y procedimientos almacenados
- Datos de ejemplo y pruebas
- Documentación técnica
- Scripts de implementación

---

## 🗂️ **ESTRUCTURA DE ARCHIVOS POR PERSONA**

### **📁 CARPETA DE BRAD**
```
brad/
├── 01_esquema_base.sql
├── 02_normalizacion.md
└── 03_estandares_claves.sql
```

**`brad/01_esquema_base.sql`**
```sql
-- BRAD: Esquema base y normalización
CREATE DATABASE IF NOT EXISTS hospital_management 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE hospital_management;

-- Tabla de especialidades médicas (maestra)
CREATE TABLE especialidades (
    especialidad_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_especialidad VARCHAR(10) NOT NULL UNIQUE,
    nombre_especialidad VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla de médicos (3FN - sin datos redundantes)
CREATE TABLE medicos (
    medico_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_licencia VARCHAR(20) NOT NULL UNIQUE,
    cedula_profesional VARCHAR(15) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F', 'O') NOT NULL,
    telefono_contacto VARCHAR(15),
    email VARCHAR(100) NOT NULL UNIQUE,
    especialidad_id INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    
    CONSTRAINT fk_medico_especialidad 
        FOREIGN KEY (especialidad_id) 
        REFERENCES especialidades(especialidad_id)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla de pacientes (3FN - información desnormalizada)
CREATE TABLE pacientes (
    paciente_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_expediente VARCHAR(20) NOT NULL UNIQUE,
    curp VARCHAR(18) NOT NULL UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F', 'O') NOT NULL,
    tipo_sangre ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    telefono_contacto VARCHAR(15),
    email VARCHAR(100),
    direccion TEXT,
    alergias TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;
```

**`brad/03_estandares_claves.sql`**
```sql
-- BRAD: Relaciones y claves
-- Tabla de citas con relaciones
CREATE TABLE citas (
    cita_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    medico_id INT NOT NULL,
    fecha_cita DATETIME NOT NULL,
    duracion_estimada INT NOT NULL DEFAULT 30,
    tipo_cita ENUM('consulta', 'urgencia', 'seguimiento', 'revision') NOT NULL,
    estado ENUM('programada', 'confirmada', 'en_proceso', 'completada', 'cancelada') NOT NULL DEFAULT 'programada',
    motivo_consulta TEXT NOT NULL,
    notas_adicionales TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cita_paciente 
        FOREIGN KEY (paciente_id) 
        REFERENCES pacientes(paciente_id)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_cita_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(medico_id)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla de tratamientos
CREATE TABLE tratamientos (
    tratamiento_id INT AUTO_INCREMENT PRIMARY KEY,
    cita_id INT NOT NULL,
    codigo_tratamiento VARCHAR(10) NOT NULL UNIQUE,
    nombre_tratamiento VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo_tratamiento ENUM('medicamento', 'terapia', 'procedimiento', 'quirurgico') NOT NULL,
    duracion_dias INT NOT NULL,
    instrucciones TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('activo', 'completado', 'suspendido', 'cancelado') NOT NULL DEFAULT 'activo',
    costo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    
    CONSTRAINT fk_tratamiento_cita 
        FOREIGN KEY (cita_id) 
        REFERENCES citas(cita_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla de recetas
CREATE TABLE recetas (
    receta_id INT AUTO_INCREMENT PRIMARY KEY,
    tratamiento_id INT NOT NULL,
    medicamento VARCHAR(100) NOT NULL,
    dosis VARCHAR(50) NOT NULL,
    frecuencia VARCHAR(50) NOT NULL,
    via_administracion ENUM('oral', 'intravenosa', 'intramuscular', 'topica', 'sublingual') NOT NULL,
    cantidad_prescrita DECIMAL(8,2) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    instrucciones_especiales TEXT,
    fecha_prescripcion DATE NOT NULL DEFAULT (CURRENT_DATE),
    
    CONSTRAINT fk_receta_tratamiento 
        FOREIGN KEY (tratamiento_id) 
        REFERENCES tratamientos(tratamiento_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;
```

---

### **📁 CARPETA DE BRIGITTE**
```
brigitte/
├── 01_restricciones_integridad.sql
├── 02_validaciones_check.sql
└── 03_estandares_calidad.md
```

**`brigitte/01_restricciones_integridad.sql`**
```sql
-- BRIGITTE: Restricciones de integridad SQL:2016

-- Restricciones para especialidades
ALTER TABLE especialidades
ADD CONSTRAINT chk_codigo_especialidad 
    CHECK (LENGTH(codigo_especialidad) >= 2);

-- Restricciones para médicos
ALTER TABLE medicos
ADD CONSTRAINT chk_email_valido 
    CHECK (email LIKE '%_@__%.__%'),
ADD CONSTRAINT chk_fecha_nacimiento_valida 
    CHECK (fecha_nacimiento <= CURRENT_DATE),
ADD CONSTRAINT chk_edad_minima_medico 
    CHECK (TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURRENT_DATE) >= 18),
ADD CONSTRAINT chk_telefono_formato
    CHECK (telefono_contacto IS NULL OR telefono_contacto REGEXP '^[0-9()-]+$');

-- Restricciones para pacientes
ALTER TABLE pacientes
ADD CONSTRAINT chk_curp_formato 
    CHECK (LENGTH(curp) = 18 AND curp REGEXP '^[A-Z]{4}[0-9]{6}[A-Z]{6}[0-9A-Z]{2}$'),
ADD CONSTRAINT chk_email_paciente_valido 
    CHECK (email IS NULL OR email LIKE '%_@__%.__%'),
ADD CONSTRAINT chk_fecha_nacimiento_paciente 
    CHECK (fecha_nacimiento <= CURRENT_DATE),
ADD CONSTRAINT chk_edad_maxima_paciente
    CHECK (TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURRENT_DATE) <= 120);
```

**`brigitte/02_validaciones_check.sql`**
```sql
-- BRIGITTE: Validaciones adicionales con CHECK

-- Restricciones para citas
ALTER TABLE citas
ADD CONSTRAINT chk_duracion_estimada 
    CHECK (duracion_estimada BETWEEN 15 AND 240),
ADD CONSTRAINT chk_fecha_cita_futura 
    CHECK (fecha_cita >= DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 HOUR)),
ADD CONSTRAINT chk_motivo_no_vacio
    CHECK (LENGTH(TRIM(motivo_consulta)) > 0);

-- Restricciones para tratamientos
ALTER TABLE tratamientos
ADD CONSTRAINT chk_duracion_tratamiento 
    CHECK (duracion_dias > 0 AND duracion_dias <= 365),
ADD CONSTRAINT chk_fechas_tratamiento 
    CHECK (fecha_fin > fecha_inicio),
ADD CONSTRAINT chk_costo_no_negativo 
    CHECK (costo >= 0),
ADD CONSTRAINT chk_nombre_tratamiento_valido
    CHECK (LENGTH(TRIM(nombre_tratamiento)) >= 3);

-- Restricciones para recetas
ALTER TABLE recetas
ADD CONSTRAINT chk_cantidad_positiva 
    CHECK (cantidad_prescrita > 0),
ADD CONSTRAINT chk_fecha_prescripcion_valida 
    CHECK (fecha_prescripcion <= CURRENT_DATE),
ADD CONSTRAINT chk_dosis_valida
    CHECK (LENGTH(TRIM(dosis)) > 0),
ADD CONSTRAINT chk_frecuencia_valida
    CHECK (LENGTH(TRIM(frecuencia)) > 0);
```

**`brigitte/03_estandares_calidad.md`**
```markdown
# 📋 ESTÁNDARES SQL:2016 APLICADOS - Brigitte

## 1. RESTRICCIONES DE INTEGRIDAD
- ✅ NOT NULL en campos obligatorios
- ✅ UNIQUE para identificadores únicos
- ✅ CHECK constraints para validación de datos
- ✅ DEFAULT values para valores predeterminados

## 2. VALIDACIONES IMPLEMENTADAS
- Formato de email válido
- CURP con formato oficial mexicano
- Fechas coherentes (no futuras para nacimientos)
- Edades mínimas/máximas realistas
- Formatos de teléfono
- Valores monetarios no negativos

## 3. ESTÁNDARES SQL:2016 ESPECÍFICOS
- Expresiones regulares en CHECK constraints
- Funciones de fecha en validaciones
- Columnas calculadas virtuales
- Tipos de datos específicos por dominio
```

---

### **📁 CARPETA DE EMMY**
```
emmy/
├── 01_vistas_procedimientos.sql
├── 02_datos_ejemplo.sql
├── 03_funciones_avanzadas.sql
└── 04_documentacion_tecnica.md
```

**`emmy/01_vistas_procedimientos.sql`**
```sql
-- EMMY: Vistas y procedimientos almacenados

-- Vista para citas del día
CREATE VIEW vista_citas_hoy AS
SELECT 
    c.cita_id,
    CONCAT(p.nombre, ' ', p.apellido_paterno) AS paciente,
    CONCAT(m.nombre, ' ', m.apellido_paterno) AS medico,
    e.nombre_especialidad AS especialidad,
    c.fecha_cita,
    c.tipo_cita,
    c.estado
FROM citas c
INNER JOIN pacientes p ON c.paciente_id = p.paciente_id
INNER JOIN medicos m ON c.medico_id = m.medico_id
INNER JOIN especialidades e ON m.especialidad_id = e.especialidad_id
WHERE DATE(c.fecha_cita) = CURRENT_DATE
ORDER BY c.fecha_cita;

-- Vista para tratamientos activos
CREATE VIEW vista_tratamientos_activos AS
SELECT 
    t.tratamiento_id,
    t.nombre_tratamiento,
    CONCAT(p.nombre, ' ', p.apellido_paterno) AS paciente,
    CONCAT(m.nombre, ' ', m.apellido_paterno) AS medico_principal,
    t.fecha_inicio,
    t.fecha_fin,
    t.estado
FROM tratamientos t
INNER JOIN citas c ON t.cita_id = c.cita_id
INNER JOIN pacientes p ON c.paciente_id = p.paciente_id
INNER JOIN medicos m ON c.medico_id = m.medico_id
WHERE t.estado = 'activo';
```

**`emmy/02_datos_ejemplo.sql`**
```sql
-- EMMY: Datos de ejemplo para pruebas

-- Insertar especialidades
INSERT INTO especialidades (codigo_especialidad, nombre_especialidad, descripcion) VALUES
('CAR', 'Cardiología', 'Especialidad en enfermedades del corazón'),
('PED', 'Pediatría', 'Medicina para niños y adolescentes'),
('DER', 'Dermatología', 'Especialidad en enfermedades de la piel'),
('GAS', 'Gastroenterología', 'Enfermedades del sistema digestivo'),
('ORL', 'Otorrinolaringología', 'Enfermedades de oído, nariz y garganta');

-- Insertar médicos
INSERT INTO medicos (numero_licencia, cedula_profesional, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono_contacto, email, especialidad_id) VALUES
('LIC123456', 'CED789012', 'María', 'García', 'López', '1980-05-15', 'F', '555-123-4567', 'maria.garcia@hospital.com', 1),
('LIC654321', 'CED123456', 'Carlos', 'Rodríguez', 'Martínez', '1975-08-22', 'M', '555-987-6543', 'carlos.rodriguez@hospital.com', 2),
('LIC789012', 'CED345678', 'Ana', 'Fernández', 'Gómez', '1982-11-30', 'F', '555-456-7890', 'ana.fernandez@hospital.com', 3);

-- Insertar pacientes
INSERT INTO pacientes (numero_expediente, curp, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, tipo_sangre, telefono_contacto, email, direccion) VALUES
('EXP001', 'GARM800515MDFLPR01', 'Ana', 'López', 'Gómez', '1990-03-10', 'F', 'A+', '555-111-2233', 'ana.lopez@email.com', 'Calle Primavera 123, CDMX'),
('EXP002', 'RODC750822HDFMTR02', 'Juan', 'Martínez', 'Díaz', '1985-07-20', 'M', 'O+', '555-444-5566', 'juan.martinez@email.com', 'Av. Reforma 456, CDMX'),
('EXP003', 'FEGA821130MDFRMA03', 'Sofía', 'Ramírez', 'Hernández', '1995-12-15', 'F', 'B-', '555-777-8899', 'sofia.ramirez@email.com', 'Calle Luna 789, CDMX');
```

**`emmy/03_funciones_avanzadas.sql`**
```sql
-- EMMY: Funciones y procedimientos avanzados

-- Función para calcular edad
DELIMITER //
CREATE FUNCTION calcular_edad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END//
DELIMITER ;

-- Procedimiento para programar cita
DELIMITER //
CREATE PROCEDURE programar_cita(
    IN p_paciente_id INT,
    IN p_medico_id INT,
    IN p_fecha_cita DATETIME,
    IN p_tipo_cita ENUM('consulta', 'urgencia', 'seguimiento', 'revision'),
    IN p_motivo_consulta TEXT
)
BEGIN
    DECLARE paciente_existe INT DEFAULT 0;
    DECLARE medico_existe INT DEFAULT 0;
    
    -- Validar existencia
    SELECT COUNT(*) INTO paciente_existe FROM pacientes 
    WHERE paciente_id = p_paciente_id AND activo = TRUE;
    
    SELECT COUNT(*) INTO medico_existe FROM medicos 
    WHERE medico_id = p_medico_id AND activo = TRUE;
    
    IF paciente_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Paciente no encontrado o inactivo';
    END IF;
    
    IF medico_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Médico no encontrado o inactivo';
    END IF;
    
    IF p_fecha_cita < NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de cita debe ser futura';
    END IF;
    
    -- Insertar la cita
    INSERT INTO citas (
        paciente_id, 
        medico_id, 
        fecha_cita, 
        tipo_cita, 
        motivo_consulta
    ) VALUES (
        p_paciente_id,
        p_medico_id,
        p_fecha_cita,
        p_tipo_cita,
        p_motivo_consulta
    );
    
    SELECT LAST_INSERT_ID() AS nueva_cita_id;
END//
DELIMITER ;

-- Procedimiento para generar reporte mensual
DELIMITER //
CREATE PROCEDURE generar_reporte_mensual(IN mes INT, IN anio INT)
BEGIN
    SELECT 
        e.nombre_especialidad,
        COUNT(DISTINCT c.medico_id) AS medicos_activos,
        COUNT(c.cita_id) AS total_citas,
        COUNT(CASE WHEN c.estado = 'completada' THEN 1 END) AS citas_completadas,
        AVG(t.costo) AS costo_promedio_tratamiento
    FROM especialidades e
    LEFT JOIN medicos m ON e.especialidad_id = m.especialidad_id
    LEFT JOIN citas c ON m.medico_id = c.medico_id 
        AND MONTH(c.fecha_cita) = mes 
        AND YEAR(c.fecha_cita) = anio
    LEFT JOIN tratamientos t ON c.cita_id = t.cita_id
    GROUP BY e.especialidad_id, e.nombre_especialidad;
END//
DELIMITER ;
```

---

## 🚀 **SCRIPT DE INTEGRACIÓN FINAL**

**`hospital_management_completo.sql`**
```sql
-- SISTEMA DE GESTIÓN HOSPITALARIA - EQUIPO: Brad, Brigitte, Emmy
-- Integración de todos los módulos

-- 1. ESQUEMA BASE (Brad)
SOURCE brad/01_esquema_base.sql;
SOURCE brad/03_estandares_claves.sql;

-- 2. RESTRICCIONES E INTEGRIDAD (Brigitte)
SOURCE brigitte/01_restricciones_integridad.sql;
SOURCE brigitte/02_validaciones_check.sql;

-- 3. FUNCIONALIDADES AVANZADAS (Emmy)
SOURCE emmy/01_vistas_procedimientos.sql;
SOURCE emmy/03_funciones_avanzadas.sql;

-- 4. DATOS DE EJEMPLO (Emmy)
SOURCE emmy/02_datos_ejemplo.sql;

-- Mensaje de finalización
SELECT '✅ SISTEMA HOSPITALARIO IMPLEMENTADO EXITOSAMENTE' AS mensaje;
SELECT '👨‍💼 Brad: Esquema y normalización' AS contribucion;
SELECT '👩‍💼 Brigitte: Estándares SQL y calidad' AS contribucion;
SELECT '👩‍⚕️ Emmy: Funcionalidades y datos' AS contribucion;
```

---

## 📊 **CRONOGRAMA DE TRABAJO**

| Día | Brad | Brigitte | Emmy |
|-----|------|----------|------|
| 1 | Diseño modelo | Investigar estándares | Preparar datos prueba |
| 2 | Crear tablas | Implementar CHECK | Desarrollar vistas |
| 3 | Normalización | Validaciones | Procedimientos |
| 4 | Integración | Control calidad | Documentación |
| 5 | Revisión final | Pruebas integridad | Pruebas funcionales |

---

## 🎯 **ENTREGABLES FINALES**

1. **Brad:** Modelo normalizado + relaciones + documentación
2. **Brigitte:** Restricciones SQL:2016 + validaciones + estándares
3. **Emmy:** Vistas + procedimientos + datos + documentación técnica
4. **Equipo:** Script integrado + documentación completa

¿Necesitan que ajuste alguna parte específica de la distribución de tareas?
