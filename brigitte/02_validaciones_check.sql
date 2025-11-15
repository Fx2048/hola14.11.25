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
