CREATE DATABASE IF NOT EXISTS houseservices CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE houseservices;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Seleccionar base de datos
USE houseservices;

-- ========================================
-- 3.3.1 Tabla roles
-- ========================================

CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) UNIQUE NOT NULL
);

-- ========================================
-- 3.3.2 Tabla usuarios
-- ========================================

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  firebase_uid VARCHAR(100) UNIQUE,
  dni VARCHAR(15) UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  apellido_1 VARCHAR(100) NOT NULL,
  apellido_2 VARCHAR(100),
  fecha_nacimiento DATE,
  telefono VARCHAR(20) UNIQUE,
  correo VARCHAR(255) UNIQUE,
  activo INT DEFAULT 1,
  primer_inicio INT DEFAULT 0
);

-- ========================================
-- 3.3.3 Tabla usuarios_roles
-- ========================================

CREATE TABLE usuarios_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  rol_id INT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- ========================================
-- 3.3.4 Tabla usuarios_ubicacion
-- ========================================

CREATE TABLE usuarios_ubicacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  latitud DOUBLE NOT NULL,
  longitud DOUBLE NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- ========================================
-- 3.3.5 Tabla usuarios_fcm_tokens
-- ========================================

CREATE TABLE usuarios_fcm_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  fcm_token VARCHAR(500) NOT NULL,
  plataforma ENUM('android', 'ios', 'web') NOT NULL,
  activo INT DEFAULT 1 COMMENT '0 = inactivo, 1 = activo',
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_token (usuario_id, fcm_token)
);

-- ========================================
-- 3.3.6 Tabla usuarios_imagenes_perfil
-- ========================================

CREATE TABLE usuarios_imagenes_perfil (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  url_imagen VARCHAR(255) NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- ========================================
-- 3.3.7 Tabla servicios
-- ========================================

CREATE TABLE servicios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  icono VARCHAR(50),
  color VARCHAR(7)
);

-- ========================================
-- 3.3.8 Tabla servicios_estados
-- ========================================

CREATE TABLE servicios_estados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  estado VARCHAR(50) NOT NULL
);

-- ========================================
-- 3.3.10 Tabla servicios_disponibles
-- ========================================

CREATE TABLE servicios_disponibles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  trabajador_id INT NOT NULL,
  servicio_id INT NOT NULL,
  descripcion TEXT,
  observaciones TEXT,
  precio_hora DECIMAL(10,2),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (trabajador_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (servicio_id) REFERENCES servicios(id) ON DELETE CASCADE
);

-- ========================================
-- 3.3.11 Tabla servicios_disponibles_horarios
-- ========================================

CREATE TABLE servicios_disponibles_horarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  servicio_disponible_id INT NOT NULL,
  horario_json JSON NOT NULL,
  FOREIGN KEY (servicio_disponible_id) REFERENCES servicios_disponibles(id) ON DELETE CASCADE
);

-- ========================================
-- 3.3.12 Tabla servicios_disponibles_imagenes
-- ========================================

CREATE TABLE servicios_disponibles_imagenes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  servicio_disponible_id INT NOT NULL,
  url_imagen VARCHAR(255) NOT NULL,
  FOREIGN KEY (servicio_disponible_id) REFERENCES servicios_disponibles(id) ON DELETE CASCADE
);

-- ========================================
-- 3.3.13 Tabla servicios_contratados
-- ========================================

CREATE TABLE servicios_contratados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  servicio_disponible_id INT NOT NULL,
  fecha_confirmada DATETIME NULL,
  fecha_realizada DATETIME NULL,
  estado_id INT NOT NULL,
  horario_seleccionado JSON NOT NULL,
  observaciones TEXT,
  FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
  FOREIGN KEY (servicio_disponible_id) REFERENCES servicios_disponibles(id) ON DELETE CASCADE,
  FOREIGN KEY (estado_id) REFERENCES servicios_estados(id)
);

-- ========================================
-- 3.3.14 Tabla valoraciones
-- ========================================

CREATE TABLE valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    servicio_contratado_id INT NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    puntuacion INT NOT NULL CHECK (puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trabajador_id INT NOT NULL,
    FOREIGN KEY (servicio_contratado_id) REFERENCES servicios_contratados(id),
    FOREIGN KEY (trabajador_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id)
);

-- ========================================
-- 3.3.15 Tabla servicios_ubicacion
-- ========================================

CREATE TABLE servicios_ubicacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  servicio_contratado_id INT NOT NULL,
  latitud DOUBLE NOT NULL,
  longitud DOUBLE NOT NULL,
  FOREIGN KEY (servicio_contratado_id) REFERENCES servicios_contratados(id)
);

-- ========================================
-- INSERTS INICIALES
-- ========================================

-- Usuario eliminado (-1)
INSERT INTO usuarios
(id, firebase_uid, dni, nombre, apellido_1, apellido_2, correo, activo, primer_inicio)
VALUES
(-1, 'USUARIO_ELIMINADO', 'ELIMINADO', 'Usuario', 'Eliminado', NULL, 'usuario.eliminado@ejemplo.com', 0, 0);

-- Servicios base
INSERT INTO servicios (id, nombre, descripcion, icono, color) VALUES
(1, 'Limpieza', 'Mantenimiento y cuidado de espacios residenciales o comerciales. Tareas de limpieza general, desinfección, organización y acondicionamiento para mantener los espacios impecables.', 'cleaning_services', '#4CAF50'),
(2, 'Fontanería', 'Trabajos relacionados con instalaciones y sistemas de agua. Reparación de tuberías, desatascos, instalación de elementos sanitarios y mantenimiento de sistemas de agua potable y desagüe.', 'plumbing', '#2196F3'),
(3, 'Electricidad', 'Trabajos relacionados con sistemas eléctricos en espacios residenciales o comerciales. Instalaciones, reparaciones, mantenimiento preventivo y solución de problemas eléctricos.', 'electrical_services', '#FFC107'),
(4, 'Peluquería', 'Servicios de corte, peinado, coloración y tratamientos para el cabello. Atención personalizada adaptada a diferentes estilos, tipos de cabello y necesidades específicas.', 'content_cut', '#9C27B0'),
(5, 'Masajes', 'Técnicas manuales aplicadas para aliviar tensiones musculares, reducir el estrés y mejorar el bienestar general. Diferentes modalidades según las necesidades de cada persona.', 'spa', '#FF5722'),
(6, 'Mecánica', 'Servicios de diagnóstico, reparación y mantenimiento de vehículos. Soluciones para problemas mecánicos, eléctricos y electrónicos en diferentes tipos de automóviles.', 'car_repair', '#795548'),
(7, 'Informática', 'Asistencia técnica para equipos informáticos y dispositivos electrónicos. Solución de problemas, optimización de rendimiento, instalación de software y recuperación de datos.', 'computer', '#3F51B5'),
(8, 'Pintura', 'Aplicación de recubrimientos decorativos y protectores en superficies interiores y exteriores. Preparación de superficies, selección de materiales y ejecución de acabados de calidad.', 'format_paint', '#E91E63'),
(9, 'Jardinería', 'Cuidado y mantenimiento de espacios verdes y plantas. Poda, siembra, diseño paisajístico, control de plagas y asesoramiento sobre especies vegetales adecuadas para cada espacio.', 'local_florist', '#4CAF50'),
(10, 'Carpintería', 'Creación, reparación y restauración de elementos y estructuras de madera. Montaje de muebles, ajustes, acabados y soluciones personalizadas en trabajos con madera.', 'carpenter', '#795548');

-- Roles base
INSERT INTO roles (id, nombre) VALUES
(1, 'Superusuario'),
(2, 'Usuario'),
(3, 'Trabajador');

-- Estados de servicios
INSERT INTO servicios_estados (estado) VALUES
('solicitado'),
('confirmado'),
('rechazado'),
('en_progreso'),
('completado');