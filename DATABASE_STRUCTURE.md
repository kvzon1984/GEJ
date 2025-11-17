# Estructura de Base de Datos Firebase

## Estructura General

La base de datos está organizada en Firebase Firestore con la siguiente jerarquía:

```
cities (collection)
├── Santiago (document)
│   └── members (subcollection)
│       ├── memberId1 (document)
│       ├── memberId2 (document)
│       └── ...
├── Valdivia (document)
│   └── members (subcollection)
│       └── ...
├── Villarrica (document)
│   └── members (subcollection)
│       └── ...
└── Paine (document)
    └── members (subcollection)
        └── ...
```

## Colecciones Principales

### Collection: `cities`

Contiene documentos para cada ciudad (Santiago, Valdivia, Villarrica, Paine).

### Subcollection: `members`

Cada documento de ciudad contiene una subcolección `members` con los miembros de esa ciudad.

## Estructura de Documentos

### Document: Member

Cada documento de miembro contiene los siguientes campos:

| Campo | Tipo | Descripción | Requerido |
|-------|------|-------------|-----------|
| `name` | String | Nombre completo del miembro | Sí |
| `email` | String | Correo electrónico | Sí |
| `phone` | String | Número de teléfono | Sí |
| `isNew` | Boolean | Indica si es un miembro nuevo | Sí |
| `region` | String | Región (ej: Metropolitana, Los Ríos) | Sí |
| `comuna` | String | Comuna donde reside | Sí |
| `prayerRequest` | String | Peticiones de oración | No |
| `observations` | String | Observaciones adicionales | No |
| `createdAt` | Timestamp | Fecha de creación del registro | Sí |
| `updatedAt` | Timestamp | Fecha de última actualización | Sí |

## Ejemplo de Documento

```json
{
  "name": "Juan Pérez García",
  "email": "juan.perez@example.com",
  "phone": "+56912345678",
  "isNew": true,
  "region": "Metropolitana",
  "comuna": "Providencia",
  "prayerRequest": "Oración por mi familia y trabajo",
  "observations": "Visitó la iglesia por primera vez en Diciembre 2024",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

## Reglas de Lógica de Negocio

### Región según Ciudad

| Ciudad | Región |
|--------|--------|
| Santiago | Metropolitana |
| Paine | Metropolitana |
| Valdivia | Los Ríos |
| Villarrica | Los Ríos |

### Comuna según Ciudad

#### Paine
- Comuna fija: `"Santiago - Paine"`
- No se puede modificar

#### Santiago
- Dropdown con comunas de la Región Metropolitana
- Opción "Otra" para ingresar comuna personalizada
- Comunas predefinidas:
  - Santiago Centro, Providencia, Las Condes, Vitacura, Lo Barnechea
  - Ñuñoa, La Reina, Macul, Peñalolén, La Florida
  - Maipú, Pudahuel, Cerrillos, Estación Central
  - Pedro Aguirre Cerda, San Miguel, La Cisterna
  - San Ramón, La Granja, El Bosque, La Pintana
  - San Bernardo, Puente Alto, Quilicura, Renca
  - Conchalí, Huechuraba, Independencia, Recoleta
  - Cerro Navia, Lo Prado, Quinta Normal

#### Valdivia
- Dropdown con comunas de la provincia
- Opción "Otra" para ingresar comuna personalizada
- Comunas predefinidas:
  - Valdivia Centro, Las Ánimas, Collico, Niebla, Corral
  - Los Lagos, Futrono, Mariquina, Lanco, Panguipulli

#### Villarrica
- Dropdown con comunas de la provincia
- Opción "Otra" para ingresar comuna personalizada
- Comunas predefinidas:
  - Villarrica Centro, Pucón, Curarrehue, Lican Ray, Coñaripe

## Operaciones CRUD

### Create (Crear Miembro)
```dart
await FirestoreService().addMember(
  cityName: 'Santiago',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  phone: '+56912345678',
  isNew: true,
  region: 'Metropolitana',
  comuna: 'Providencia',
  prayerRequest: 'Oración por salud',
  observations: 'Primera visita',
);
```

### Read (Leer Miembros)
```dart
Stream<QuerySnapshot> membersStream = FirestoreService().getMembers('Santiago');
```

### Update (Actualizar Miembro)
```dart
await FirestoreService().updateMember(
  cityName: 'Santiago',
  memberId: 'abc123',
  name: 'Juan Pérez García',
  email: 'juan.nuevo@example.com',
  phone: '+56987654321',
  isNew: false,
  region: 'Metropolitana',
  comuna: 'Las Condes',
  prayerRequest: 'Oración por trabajo',
  observations: 'Actualizado',
);
```

### Delete (Eliminar Miembro)
```dart
await FirestoreService().deleteMember(
  cityName: 'Santiago',
  memberId: 'abc123',
);
```

## Índices Recomendados

Para optimizar las consultas en Firebase, se recomienda crear los siguientes índices:

1. **Índice compuesto:**
   - Collection: `cities/{cityId}/members`
   - Fields: `createdAt` (Descending), `name` (Ascending)

2. **Índice compuesto para búsquedas:**
   - Collection: `cities/{cityId}/members`
   - Fields: `isNew` (Ascending), `createdAt` (Descending)

## Reglas de Seguridad Sugeridas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regla para miembros
    match /cities/{city}/members/{member} {
      // Permitir lectura solo a usuarios autenticados
      allow read: if request.auth != null;
      
      // Permitir escritura solo a usuarios autenticados
      allow create, update: if request.auth != null
        && request.resource.data.keys().hasAll([
          'name', 'email', 'phone', 'isNew', 'region', 
          'comuna', 'prayerRequest', 'observations', 
          'createdAt', 'updatedAt'
        ])
        && request.resource.data.name is string
        && request.resource.data.email is string
        && request.resource.data.phone is string
        && request.resource.data.isNew is bool
        && request.resource.data.region is string
        && request.resource.data.comuna is string;
      
      // Permitir eliminación solo a usuarios autenticados
      allow delete: if request.auth != null;
    }
  }
}
```

## Cómo Configurar en Firebase Console

1. **Ir a Firebase Console:** https://console.firebase.google.com/
2. **Seleccionar proyecto:** gejv1-83264
3. **Ir a Firestore Database**
4. **Crear base de datos** (si no existe)
   - Modo: Production
   - Ubicación: us-central (o la más cercana)
5. **Habilitar Authentication**
   - Ir a Authentication → Sign-in method
   - Habilitar Email/Password
6. **Aplicar reglas de seguridad**
   - Ir a Firestore → Rules
   - Copiar y pegar las reglas sugeridas arriba
   - Publicar los cambios

## Notas Importantes

- Todos los campos de texto vacíos se guardan como strings vacíos `""`, no como `null`
- Las fechas `createdAt` y `updatedAt` se generan automáticamente en el servidor
- El `id` del documento se genera automáticamente por Firestore
- La estructura jerárquica permite consultas eficientes por ciudad
- Los campos `prayerRequest` y `observations` son opcionales y pueden estar vacíos
