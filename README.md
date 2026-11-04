# Directorio Dolorense

Directorio de negocios de Dolores Hidalgo construido con Flutter y una API
REST local en Node.js. La app lista, agrega, marca favoritos y elimina
negocios; además maneja los cinco estados de una pantalla de red: inicial,
cargando, listo, vacío y error.

Proyecto del manual **TDD · Consumo de una API local desde Flutter**
(Desarrollo Móvil Integral · UTNG).

## Estructura

```
directorio_dolorense/
├── api/
│   └── server.js              # API REST en Node (sin dependencias)
├── lib/
│   ├── dominio/               # Negocio y excepciones (Dart puro)
│   │   ├── negocio.dart
│   │   └── excepciones.dart
│   ├── datos/                 # Cliente HTTP y URL base
│   │   ├── negocios_api.dart
│   │   └── config_api.dart
│   ├── presentacion/          # ViewModel y pantalla
│   │   ├── negocios_viewmodel.dart
│   │   └── pantalla_negocios.dart
│   └── main.dart              # Composition root
└── test/
    ├── negocio_test.dart
    ├── negocios_api_test.dart
    ├── viewmodel_test.dart
    └── pantalla_negocios_test.dart
```

> El manual usa una carpeta `app/` porque crea el proyecto Flutter dentro de
> ella. En este repositorio el proyecto Flutter es la raíz, por eso las fuentes
> viven en `lib/` y las pruebas en `test/`.

## Requisitos

- Flutter 3.x (`flutter doctor` sin errores graves)
- Node.js 18 o superior
- Para probar en un celular real: PC y celular en la misma red Wi-Fi

## 1. Encender la API

```bash
cd api
node server.js
```

Debe aparecer:

```
API lista en http://localhost:3000/negocios
```

Comprobación rápida desde otra terminal:

```bash
curl localhost:3000/salud
curl localhost:3000/negocios
```

### Endpoints

| Método | Ruta            | Acción                          |
|--------|-----------------|---------------------------------|
| GET    | `/negocios`     | Listar (acepta `?q=texto`)      |
| GET    | `/negocios/:id` | Obtener uno                     |
| POST   | `/negocios`     | Crear (`nombre` y `categoria`)  |
| PUT    | `/negocios/:id` | Actualizar                      |
| DELETE | `/negocios/:id` | Eliminar                        |
| GET    | `/salud`        | Estado del servidor             |

Los datos viven en memoria: al reiniciar el servidor se restauran los cinco
negocios iniciales.

## 2. Ejecutar la app

```bash
flutter pub get
flutter run
```

La URL se elige automáticamente:

- Emulador Android → `http://10.0.2.2:3000`
- Simulador iOS / escritorio → `http://localhost:3000`
- Celular real → pasa la IP de tu PC:

```bash
flutter run --dart-define=API_URL=http://192.168.1.50:3000
```

Antes de probar en el celular, abre en su navegador
`http://TU-IP:3000/salud`; debe responder `{"ok":true}`.

## 3. Pruebas

Todas usan `MockClient`: no necesitan red ni servidor encendido.

```bash
flutter test
flutter analyze
```

## Qué se practica

- Modelo con `desdeJson`, `aJson` y `copiarCon` (sin mandar `id` al crear).
- Excepciones de dominio: `SinConexionException`,
  `ErrorServidorException` y `RespuestaInvalidaException`.
- Cliente HTTP con timeout, validación de `statusCode` y traducción de fallos.
- ViewModel con `ChangeNotifier` y estados `inicial`, `cargando`, `listo`,
  `vacio` y `error`.
- Pantalla con `RefreshIndicator`, `Dismissible`, favoritos y botón
  `Reintentar`.
- Pruebas de modelo, API, ViewModel y widgets.
