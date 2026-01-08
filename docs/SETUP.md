# Setup HouseServices

Este documento explica como realiar la configuracion y el arranque para MySQL + Backend (Docker), de manera que ya esta todo preconfigurado para que sea mas facil montar la respectiva infraesctructura.
También al final de este documento, veremos los archvios necesarios para que la APP ( forntend ) pueda arrancar sin problemas.

---

## Requisitos
- Docker + Docker Compose
- (opcional) Java 17 si se ejecuta el backend sin Docker
- Flutter si se ejecuta la app

---

## 1) Levantar con Docker (MySQL + Backend)

### 1.1 Variables de entorno
Se usa el fichero `infra/.env` para definir las variables usadas por `infra/docker-compose.yml`.

1. Crear el fichero local a partir del ejemplo:
   - `cp infra/.env.example infra/.env`

2. Editar `infra/.env` y rellenar los valores. Estos valores son los que se van a utilizar para algunas configuraciones internas a la hora de levantar la infraestructura ( BBDD MySQL, Puerto del Backend, JSON Firebase... ).

3. Contenido y para que sirve cada variable:

### MYSQL_PORT
Puerto en tu maquina/servidor donde se expone MySQL.
Ej: 3306. Si ya tienes MySQL en el servidor, puedes poner otro (ej: 3307).

### MYSQL_DATABASE
Nombre de la base de datos que se crea al iniciar el contenedor.
Ej: houseservices.

### MYSQL_USER / MYSQL_PASSWORD
Usuario y contraseña que usará el backend para conectarse a MySQL.

### MYSQL_ROOT_PASSWORD
Contraseña del usuario root de MySQL (para tareas de admin/debug).

### BACKEND_PORT
Puerto en tu maquina/servidor donde se expone el backend.
Ej: 8080.

### FIREBASE_STORAGE_BUCKET
Bucket de Firebase Storage del proyecto (el backend lo usa para subir/leer ficheros).
Debe coincidir con el proyecto del firebase-service-account.json. Este se obtiene desde la consola de Firebase ya que es el nombre principal y suele tener un formato similar a:
`nombre-proyecto.appspot.com`.

### 1.2 Ficheros necesarios (secrets)
Para que el backend arranque con Docker, se esperan estos ficheros locales:

- `infra/secrets/application.properties`
- `infra/secrets/firebase-service-account.json`

Si la carpeta no existe, se crea:
- `mkdir -p infra/secrets`

#### Plantillas disponibles
Las plantillas de ejemplo se encuentran en el backend con estas respectivas rutas:

- `backend/src/main/resources/application.properties.example`
- `backend/src/main/resources/firebase-service-account.example.json`

Se pueden usar como base:

- `cp backend/src/main/resources/application.properties.example infra/secrets/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json infra/secrets/firebase-service-account.json`

El fichero `application.properties` es el fichero de configuración para la conexión de MySQL y `firebase-service-account.json` debe ser reemplazado por el JSON real del Admin SDK descargado desde Firebase.

#### Importante (Docker): host de MySQL (application.properties)
Esto afecta a la configuracion de base de datos del backend, concretamente a:

- `spring.datasource.url` (dentro de `application.properties`)

Cuando el backend corre dentro de Docker, `localhost` apunta al propio contenedor del backend (no al contenedor de MySQL).
Por eso, en Docker el host debe ser el nombre del servicio de MySQL definido en `infra/docker-compose.yml`:

- servicio: `mysql`
- host correcto: `mysql`

Ejemplo para Docker (en `infra/secrets/application.properties`):

- `spring.datasource.url=jdbc:mysql://mysql:3306/houseservices`

En ejecucion local sin Docker normalmente seria:

- `spring.datasource.url=jdbc:mysql://localhost:3306/houseservices`

### 1.3 Ejecutar
- `cd infra`
- `docker compose --env-file .env up -d --build`

Servicios:
- MySQL: `localhost:${MYSQL_PORT}`
- Backend: `http://localhost:${BACKEND_PORT}`

### 1.4 Dockerfile del backend
El contenedor del backend se construye a partir de `backend/Dockerfile` porque en `infra/docker-compose.yml` se usa:

- `build: ../backend`

---

## 2) Frontend (Flutter)

### 2.1 Ficheros necesarios

Para que la app Flutter funcione con Firebase hacen falta 2 ficheros de configuracion:

La configuracion de Firebase para Android que se descarga desde la consola de Firebase:

- `frontend/android/app/google-services.json`

Un fichero generado para Flutter (opciones de Firebase por plataforma) que normalmente se genera con FlutterFire (por ejemplo con `flutterfire configure`):

- `frontend/lib/config/firebase_options.dart`

En el caso de que no utilizar ningun comando para generar `firebase_options.dart`, se puede coger el fichero de la siguiente linea de ejemplo. En este solo será necesario sustituir los valores en la plataforma que se quiera arrancar la APP ( web, ios o android ), por los valores reales.

En el repositorio hay plantillas de ejemplo:

- `frontend/android/app/google-services.example.json`
- `frontend/lib/config/firebase_options.example.dart`

Cuando se tenga la configuracion real, los ficheros deben existir con estos nombres:

- `frontend/android/app/google-services.json`
- `frontend/lib/config/firebase_options.dart`

Por último y muy importante, se deberá crear un fichero para establecer la API Key de Google Maps ya que la APP utiliza un mapa que hace llamadas respectivamente a esa Api. Por ello se deberá crear el siguiente fichero:

- `frontend/android/app/src/main/res/values/google_maps_api.xml`

Con un contenido como este donde se insertará la respectiva API Key:

<resources>
    <string name="google_maps_key" translatable="false">
        TU_GOOGLE_MAPS_API_KEY
    </string>
</resources>

---

### 2.2 Ejecución de la APP ( frontend )

Para ejecutar la app ( obviamente teniendo flutter instalado ) se deberá ejecutar los siguientes comandos:
- `cd frontend` ( opcional, en el caso de que se este en la ruta principal de la carpeta frontend )
- `flutter pub get`

Por último, la app Flutter obtiene la URL del backend mediante una variable de entorno
definida en tiempo de ejecución. Por ello es obligatorio arrancar la app indicando la URL del backend con
`--dart-define`.

`flutter run --dart-define=URL_BASE={URL_DEL_BACKEND}/api`

## Información adicional

Esta información adicional es interesante conocer para el funcionamiento correcto del proyecto 
en el caso de que se quiera reinicializar o levantar de nuevo la infraestructura.

1) Resetear base de datos (re-ejecutar init SQL)

Los scripts de inicializacion estan en:
- `infra/db/init/`

Para reinicializar desde cero:

- `cd infra`
- `docker compose down -v`
- `docker compose --env-file .env up -d --build`

---

2) Backend sin Docker (local)

En ejecucion local, el backend espera los ficheros dentro de resources:

- `backend/src/main/resources/application.properties`
- `backend/src/main/resources/firebase-service-account.json`

Se pueden crear a partir de los ejemplos:

- `cp backend/src/main/resources/application.properties.example backend/src/main/resources/application.properties`
- `cp backend/src/main/resources/firebase-service-account.example.json backend/src/main/resources/firebase-service-account.json`

Ejecutar:
- `cd backend`
- `./gradlew bootRun`