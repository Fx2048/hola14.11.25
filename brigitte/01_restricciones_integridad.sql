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
