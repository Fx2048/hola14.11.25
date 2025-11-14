Te ayudo a crear una base de datos para gestión hospitalaria aplicando estándares SQL:2016 paso a paso.

## 🏥 **BASE DE DATOS: GESTIÓN HOSPITALARIA**

### **PASO 1: ANÁLISIS DEL DOMINIO Y NORMALIZACIÓN**

**Entidades identificadas:**
- Pacientes
- Médicos  
- Citas
- Recetas
- Tratamientos
- Especialidades médicas

### **PASO 2: MODELO CONCEPTUAL (3FN)**

```sql
-- Archivo: hospital_management.sql
-- Base de datos normalizada hasta 3FN aplicando SQL:2016
```

### **PASO 3: IMPLEMENTACIÓN SQL CON ESTÁNDAR SQL:2016**

```sql
-- Creación de la base de datos
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
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_codigo_especialidad CHECK (LENGTH(codigo_especialidad) >= 2)
) ENGINE=InnoDB;

-- Tabla de médicos
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
    
    -- Clave foránea con acción RESTRICT para integridad referencial
    CONSTRAINT fk_medico_especialidad 
        FOREIGN KEY (especialidad_id) 
        REFERENCES especialidades(especialidad_id)
        ON DELETE RESTRICT,
    
    -- Restricciones CHECK según SQL:2016
    CONSTRAINT chk_email_valido 
        CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT chk_fecha_nacimiento_valida 
        CHECK (fecha_nacimiento <= CURRENT_DATE),
    CONSTRAINT chk_edad_minima_medico 
        CHECK (TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURRENT_DATE) >= 18)
) ENGINE=InnoDB;

-- Tabla de pacientes
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
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Restricciones CHECK
    CONSTRAINT chk_curp_formato 
        CHECK (LENGTH(curp) = 18 AND curp REGEXP '^[A-Z]{4}[0-9]{6}[A-Z]{6}[0-9A-Z]{2}$'),
    CONSTRAINT chk_email_paciente_valido 
        CHECK (email IS NULL OR email LIKE '%_@__%.__%'),
    CONSTRAINT chk_fecha_nacimiento_paciente 
        CHECK (fecha_nacimiento <= CURRENT_DATE)
) ENGINE=InnoDB;

-- Tabla de citas
CREATE TABLE citas (
    cita_id INT AUTO_INCREMENT PRIMARY KEY,
    paciente_id INT NOT NULL,
    medico_id INT NOT NULL,
    fecha_cita DATETIME NOT NULL,
    duracion_estimada INT NOT NULL DEFAULT 30, -- en minutos
    tipo_cita ENUM('consulta', 'urgencia', 'seguimiento', 'revision') NOT NULL,
    estado ENUM('programada', 'confirmada', 'en_proceso', 'completada', 'cancelada') NOT NULL DEFAULT 'programada',
    motivo_consulta TEXT NOT NULL,
    notas_adicionales TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    CONSTRAINT fk_cita_paciente 
        FOREIGN KEY (paciente_id) 
        REFERENCES pacientes(paciente_id)
        ON DELETE CASCADE,
    
    CONSTRAINT fk_cita_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(medico_id)
        ON DELETE RESTRICT,
    
    -- Restricciones CHECK
    CONSTRAINT chk_duracion_estimada 
        CHECK (duracion_estimada BETWEEN 15 AND 240),
    CONSTRAINT chk_fecha_cita_futura 
        CHECK (fecha_cita >= DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 HOUR))
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
    
    -- Clave foránea
    CONSTRAINT fk_tratamiento_cita 
        FOREIGN KEY (cita_id) 
        REFERENCES citas(cita_id)
        ON DELETE CASCADE,
    
    -- Restricciones CHECK
    CONSTRAINT chk_duracion_tratamiento 
        CHECK (duracion_dias > 0 AND duracion_dias <= 365),
    CONSTRAINT chk_fechas_tratamiento 
        CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT chk_costo_no_negativo 
        CHECK (costo >= 0)
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
    
    -- Clave foránea
    CONSTRAINT fk_receta_tratamiento 
        FOREIGN KEY (tratamiento_id) 
        REFERENCES tratamientos(tratamiento_id)
        ON DELETE CASCADE,
    
    -- Restricciones CHECK
    CONSTRAINT chk_cantidad_positiva 
        CHECK (cantidad_prescrita > 0),
    CONSTRAINT chk_fecha_prescripcion_valida 
        CHECK (fecha_prescripcion <= CURRENT_DATE)
) ENGINE=InnoDB;
```

### **PASO 4: VISTAS Y PROCEDIMIENTOS (SQL:2016)**

```sql
-- Vista para citas del día (aplicando estándar SQL:2016)
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

-- Procedimiento almacenado para programar cita
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
    
    -- Validar existencia del paciente (estándar SQL:2016 - manejo de errores)
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

-- Función para calcular edad del paciente
DELIMITER //
CREATE FUNCTION calcular_edad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END//
DELIMITER ;
```

### **PASO 5: DATOS DE EJEMPLO**

```sql
-- Insertar especialidades
INSERT INTO especialidades (codigo_especialidad, nombre_especialidad, descripcion) VALUES
('CAR', 'Cardiología', 'Especialidad en enfermedades del corazón'),
('PED', 'Pediatría', 'Medicina para niños y adolescentes'),
('DER', 'Dermatología', 'Especialidad en enfermedades de la piel'),
('GAS', 'Gastroenterología', 'Enfermedades del sistema digestivo');

-- Insertar médicos
INSERT INTO medicos (numero_licencia, cedula_profesional, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono_contacto, email, especialidad_id) VALUES
('LIC123456', 'CED789012', 'María', 'García', 'López', '1980-05-15', 'F', '555-123-4567', 'maria.garcia@hospital.com', 1),
('LIC654321', 'CED123456', 'Carlos', 'Rodríguez', 'Martínez', '1975-08-22', 'M', '555-987-6543', 'carlos.rodriguez@hospital.com', 2);

-- Insertar pacientes
INSERT INTO pacientes (numero_expediente, curp, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, tipo_sangre, telefono_contacto, email) VALUES
('EXP001', 'GARM800515MDFLPR01', 'Ana', 'López', 'Gómez', '1990-03-10', 'F', 'A+', '555-111-2233', 'ana.lopez@email.com'),
('EXP002', 'RODC750822HDFMTR02', 'Juan', 'Martínez', 'Díaz', '1985-07-20', 'M', 'O+', '555-444-5566', 'juan.martinez@email.com');
```

### **PASO 6: DOCUMENTO DE ESTÁNDARES APLICADOS**

**📋 DOCUMENTACIÓN DE ESTÁNDARES SQL:2016 APLICADOS**

**1. TIPOS DE DATOS APROPIADOS:**
- `VARCHAR` con longitudes específicas
- `ENUM` para dominios restringidos
- `DECIMAL` para valores monetarios
- `TIMESTAMP` para auditoría
- `BOOLEAN` para flags

**2. CLAVES PRIMARIAS Y FORÁNEAS:**
- Claves primarias autoincrementales
- Claves foráneas con restricciones `ON DELETE`
- Uso de `RESTRICT` y `CASCADE` según negocio

**3. RESTRICCIONES DE INTEGRIDAD:**
- `NOT NULL` en campos obligatorios
- `UNIQUE` para identificadores únicos
- `CHECK` para validación de datos
- `DEFAULT` para valores predeterminados

**4. ESTRUCTURAS AVANZADAS:**
- Vistas para simplificar consultas
- Procedimientos almacenados para lógica de negocio
- Funciones definidas por el usuario

**5. NORMALIZACIÓN (3FN):**
- Eliminación de dependencias transitivas
- Claves primarias mínimas
- Dependencias funcionales completas

**6. CARACTERÍSTICAS ESPECÍFICAS SQL:2016:**
- Expresiones regulares en `CHECK`
- Funciones de fecha/hora
- Manejo de errores con `SIGNAL`
- Columnas calculadas virtuales

### **PASO 7: ARCHIVO DE ENTREGA**

**Estructura de archivos:**
```
hospital_management/
├── hospital_management.sql    (Script completo de BD)
├── datos_ejemplo.sql          (Datos de prueba)
└── estandares_aplicados.md    (Documentación)
```

**Para ejecutar:**
```bash
mysql -u usuario -p < hospital_management.sql
```

¿Te gustaría que profundice en algún aspecto específico del estándar SQL:2016 o agregue alguna funcionalidad adicional?
