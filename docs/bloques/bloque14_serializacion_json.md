# Bloque 14 — Serialización y Transferencia de Datos

## Objetivo
Serializar la información completa de todos los clientes a formato JSON usando FOR JSON PATH con estructura anidada.

**Valor:** 5 puntos | **Estado:** ✅ Completado

---

## Stored Procedure

| Parámetro | Valor |
|-----------|-------|
| Nombre | persona.sp_SerializarClientesJSON |
| Técnica | FOR JSON PATH con subconsultas anidadas |
| Estructura | Clientes → Contactos, Direcciones, Identificaciones |

---

## Estructura del JSON

```json
{
  "clientes": [
    {
      "Cliente_ID": 1,
      "TipoPersona": "F",
      "PrimerNombre": "Carlos",
      "PrimerApellido": "Mora",
      "FechaNacimiento": "1985-03-12",
      "EstadoCliente": "Cliente activo",
      "Contactos": [
        { "TipoMecanismoContacto_ID": 1, "Valor": "carlos.mora@gmail.com" },
        { "TipoMecanismoContacto_ID": 2, "Valor": "88012345", "CodigoArea": "506" }
      ],
      "Direcciones": [
        { "TipoDireccion_ID": 1, "LineaDireccion1": "Barrio Dent..." }
      ],
      "Identificaciones": [
        { "TipoIdentificacion_ID": 1, "Numero": "1-0752-0341" }
      ]
    }
  ]
}
```

---

## Ejecución

```sql
USE [RentaCR];
EXEC [persona].[sp_SerializarClientesJSON];
```

**Resultado:** JSON completo con los 13 clientes (10 físicos + 3 jurídicos) con sus contactos, direcciones e identificaciones anidadas.
