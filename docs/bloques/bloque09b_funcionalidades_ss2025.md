# Bloque 9 — Funcionalidades SQL Server 2025

## Objetivo
Implementar las tres nuevas funcionalidades de SQL Server 2025: Vector Search, External API calls y expresiones regulares avanzadas.

**Estado general:** ⚠️ En proceso — limitaciones de build RTM-GDR

---

## 1. Vector Data and Semantic Search

**Estado:** ⚠️ Funcional sin índice DiskANN

| Componente | Estado | Detalle |
|------------|--------|---------|
| Columna VECTOR(1536) | ✅ Implementado | vehiculo.Vehiculo.DescripcionVector |
| Datos vectoriales | ✅ Implementado | 15 vehículos con vectores sintéticos |
| VECTOR_DISTANCE | ✅ Funcional | Métrica cosine probada |
| Índice DiskANN | ⚠️ Pendiente | Sintaxis no disponible en build RTM-GDR |

### Consulta de Similitud Semántica

```sql
-- Buscar los 5 vehículos más similares a un vector de búsqueda
SELECT TOP 5
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria,
    VECTOR_DISTANCE('cosine', v.DescripcionVector, @vectorBusqueda) AS Distancia
FROM [vehiculo].[Vehiculo] v
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
WHERE v.DescripcionVector IS NOT NULL
ORDER BY Distancia ASC;
```

---

## 2. External API Calls

**Estado:** ⚠️ Feature funcional — API BCCR caída

| Componente | Estado | Detalle |
|------------|--------|---------|
| sp_invoke_external_rest_endpoint | ✅ Habilitado | external rest endpoint enabled = 1 |
| SP implementado | ✅ Completo | alquiler.sp_ObtenerTipoCambioBCCR |
| Prueba con httpbin.org | ✅ HTTP 200 | Feature funcional |
| API BCCR | ⚠️ HTTP 500 | Servicio externo caído al momento de la prueba |

### Stored Procedure

```sql
EXEC [alquiler].[sp_ObtenerTipoCambioBCCR]
    @FechaConsulta = '2026-05-26',
    @TipoCambio_ID = @id OUTPUT;
```

---

## 3. Expresiones Regulares (REGEXP_LIKE)

**Estado:** ⚠️ No disponible en build actual

| Componente | Estado | Detalle |
|------------|--------|---------|
| REGEXP_LIKE | ❌ No disponible | Build 17.0.1115.1 RTM-GDR no lo soporta |
| Compatibility Level | ✅ 170 | Correcto |
| Alternativa implementada | ✅ LIKE | Los 3 SPs usan LIKE como fallback |
| Solución | Actualizar al último CU de SS2025 | Pendiente |

### SPs con validación LIKE (temporal)

| SP | Valida |
|----|--------|
| vehiculo.sp_ValidarVehiculo | Placa: [A-Z][A-Z][A-Z]-[0-9][0-9][0-9] |
| persona.sp_ValidarContacto | Correo: LIKE '%@%.%' |
| persona.sp_ValidarIdentificacion | Cédula: [1-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] |

---

## Evidencias

Las evidencias de este bloque se encuentran en la carpeta `bloque09_arquitectura_datos` ya que comparten bloque de evaluación.

| # | Archivo | Descripción |
|---|---------|-------------|
| 1 | ![02](../../evidencias/bloque09_arquitectura_datos/02_vector_distance_busqueda_semantica.png) | Resultado de VECTOR_DISTANCE cosine — ranking de vehículos por similitud semántica |
| 2 | ![03](../../evidencias/bloque09_arquitectura_datos/03_columna_vector_1536_vehiculos.png) | Columna VECTOR(1536) en `vehiculo.Vehiculo` con datos vectoriales cargados |
| 3 | ![04](../../evidencias/bloque09_arquitectura_datos/04_stored_procedures_creados.png) | SPs de External API (`sp_ObtenerTipoCambioBCCR`) y serialización JSON visibles en el árbol de objetos |
