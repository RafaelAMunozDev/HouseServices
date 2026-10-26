# Setup HouseServices

[English](SETUP.md) · **Español**

Este documento explica cómo realizar la configuración y el arranque de MySQL + Backend (Docker), que ya está todo preconfigurado para que sea más fácil levantar la infraestructura.
Al final de este documento también veremos los archivos necesarios para que la APP (frontend) pueda arrancar sin problemas.

---

## Requisitos
- Docker + Docker Compose
- (opcional) Java 17 si se ejecuta el backend sin Docker
- Flutter si se ejecuta la app
- **Importante:** hay que tener los servicios **AUTH**, **STORAGE** y **FIRESTORE** activos en la consola del proyecto de Firebase que se vaya a utilizar, con sus respectivas reglas configuradas; si no, esos servicios no funcionarán.

---

## 1) Levantar con Docker (MySQL + Backend)

### 1.1 Variables de entorno
Se usa el fichero `infra/.env` para definir las variables que usa `infra/docker-compose.yml`.

1. Crear el fichero local a partir del ejemplo:
   - `cp infra/.env.example infra/.env`

2. Editar `infra/.env` y rellenar los valores. Estos valores se usan en algunas configuraciones internas a la hora de levantar la infraestructura (BBDD MySQL, puerto del backend, JSON de Firebase...).

3. Contenido y para qué sirve cada variable:

### MYSQL_PORT
Puerto de tu máquina/servidor donde se expone MySQL.
Ej: 3306. Si ya tienes MySQL en el servidor, puedes poner otro (ej: 3307).

### MYSQL_DATABASE
Nombre de la base de datos que se crea al iniciar el contenedor.
Ej: houseservices.

### MYSQL_USER / MYSQL_PASSWORD
Usuario y contraseña que usará el backend para conectarse a MySQL.

### MYSQL_ROOT_PASSWORD
Contraseña del usuario root de MySQL (para tareas de administración/depuración).

### BACKEND_PORT
Puerto de tu máquina/servidor donde se expone el backend.
Ej: 8080.

### FIREBASE_STORAGE_BUCKET
Bucket de Firebase Storage del proyecto (el backend lo usa para subir y leer ficheros).
Debe coincidir con el proyecto del `firebase-service-account.json`. Se obtiene desde la consola de Firebase, ya que es el nombre principal, y suele tener un formato parecido a:
`nombre-proyecto.appspot.com` o `nombre-proyecto.firebasestorage.app`.

### 1.2 Ficheros necesarios (secrets)
Para que el backend arranque con Docker, se esperan estos ficheros locales:

- `infra/secrets/application.properties`
- `infra/secrets/firebase-service-account.json`

Si la carpeta no existe, se crea:
- `mkdir -p infra/secrets`

#### Plantillas disponibles
Las plantillas de ejemplo están en el backend, en estas rutas:

- `backend/src/main/resources/application.properties.example`
- `backend/src/main/resources/firebase-service-account.example.json`

Se pueden usar como base:

- `cp backend/src/main/resources/application.properties.example infra/secrets/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json infra/secrets/firebase-service-account.json`

El fichero `application.properties` es el fichero de configuración de la conexión con MySQL, y `firebase-service-account.json` debe sustituirse por el JSON real del Admin SDK descargado desde Firebase.

#### Importante (Docker): host de MySQL (application.properties)
Esto afecta a la configuración de la base de datos del backend, concretamente a:

- `spring.datasource.url` (dentro de `application.properties`)

Cuando el backend corre dentro de Docker, `localhost` apunta al propio contenedor del backend (no al contenedor de MySQL).
Por eso, en Docker el host debe ser el nombre del servicio de MySQL definido en `infra/docker-compose.yml`:

- servicio: `mysql`
- host correcto: `mysql`

Ejemplo para Docker (en `infra/secrets/application.properties`):

- `spring.datasource.url=jdbc:mysql://mysql:3306/houseservices`

En ejecución local sin Docker normalmente sería:

- `spring.datasource.url=jdbc:mysql://localhost:3306/houseservices`

### 1.3 Ejecutar
- `cd infra`
- `docker compose --env-file .env up -d --build`

Servicios:
- MySQL: `localhost:${MYSQL_PORT}`
- Backend: `http://localhost:${BACKEND_PORT}`

### 1.4 Dockerfile del backend
El contenedor del backend se construye a partir de `backend/Dockerfile`, porque en `infra/docker-compose.yml` se usa:

- `build: ../backend`

---

## 2) Frontend (Flutter)

### 2.1 Ficheros necesarios

Para que la app Flutter funcione con Firebase hacen falta 2 ficheros de configuración.

La configuración de Firebase para Android, que se descarga desde la consola de Firebase:

- `frontend/android/app/google-services.json`

Un fichero generado para Flutter (opciones de Firebase por plataforma), que normalmente se genera con FlutterFire (por ejemplo, con `flutterfire configure`):

- `frontend/lib/config/firebase_options.dart`

Si no se utiliza ningún comando para generar `firebase_options.dart`, se puede partir del fichero de ejemplo indicado más abajo. Solo hay que sustituir por los valores reales los de la plataforma en la que se quiera arrancar la APP (web, iOS o Android).

En el repositorio hay plantillas de ejemplo:

- `frontend/android/app/google-services.example.json`
- `frontend/lib/config/firebase_options.example.dart`

Cuando se tenga la configuración real, los ficheros deben existir con estos nombres:

- `frontend/android/app/google-services.json`
- `frontend/lib/config/firebase_options.dart`

Por último, y muy importante, hay que crear un fichero con la API Key de Google Maps, ya que la APP utiliza un mapa que hace llamadas a esa API. Para ello hay que crear el siguiente fichero:

- `frontend/android/app/src/main/res/values/google_maps_api.xml`

Con un contenido como este, insertando la API Key correspondiente:

```xml
<resources>
    <string name="google_maps_key" translatable="false">
        TU_GOOGLE_MAPS_API_KEY
    </string>
</resources>
```

---

### 2.2 Ejecución de la APP (frontend)

Para ejecutar la app (con Flutter instalado) hay que ejecutar los siguientes comandos:
- `cd frontend` (si no se está ya en la carpeta frontend)
- `flutter pub get`

Por último, la app Flutter obtiene la URL del backend mediante una variable de entorno definida en tiempo de ejecución. Por eso es obligatorio arrancar la app indicando la URL del backend con `--dart-define`:

`flutter run --dart-define=URL_BASE={URL_DEL_BACKEND}/api`

Como alternativa para ejecutar la APP sin el comando anterior, se puede cambiar la URL que apunta al backend en el fichero `frontend\lib\services\ApiService.dart`, concretamente en esta línea:

- `defaultValue: 'http://10.0.2.2:8080/api'`

## Información adicional

Esta información es útil para el correcto funcionamiento del proyecto si se quiere reinicializar o volver a levantar la infraestructura.

1) Resetear la base de datos (volver a ejecutar el SQL de inicio)

Los scripts de inicialización están en:
- `infra/db/init/`

Para reinicializar desde cero:

- `cd infra`
- `docker compose down -v`
- `docker compose --env-file .env up -d --build`

---

2) Backend sin Docker (local)

En ejecución local, el backend espera los ficheros dentro de resources:

- `backend/src/main/resources/application.properties`
- `backend/src/main/resources/firebase-service-account.json`

Se pueden crear a partir de los ejemplos:

- `cp backend/src/main/resources/application.properties.example backend/src/main/resources/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json backend/src/main/resources/firebase-service-account.json`

Ejecutar:
- `cd backend`
- `./gradlew bootRun`
