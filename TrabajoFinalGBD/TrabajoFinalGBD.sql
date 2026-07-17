-- Trabajo Práctico Final Gestión de Base de Datos
-- 1 - Crear una función llamada "calcular_total_ventas" que tome como parámetro el mes y el año, y devuelva 
-- el total de ventas realizadas en ese mes. Verificar mediante consulta.
use pubs;

DELIMITER $$

CREATE FUNCTION calcular_total_ventas(
    p_mes INT,
    p_anio INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC

BEGIN

    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(s.qty * t.price),0)
    INTO total
    FROM sales s
    INNER JOIN titles t
        ON s.title_id = t.title_id
    WHERE MONTH(s.ord_date) = p_mes
      AND YEAR(s.ord_date) = p_anio;

    RETURN total;

END $$

DELIMITER ;

-- Consultas

SELECT calcular_total_ventas(3,1994) AS Total_Ventas;
SELECT calcular_total_ventas(11,1990);

-- 2 - Crear una función llamada "obtener_nombre_empleado" que tome como parámetro el ID de un empleado y devuelva su nombre completo. Verificar mediante consulta.

DELIMITER $$

CREATE FUNCTION obtener_nombre_empleado(
    p_emp_id INT
)
RETURNS VARCHAR(60)
DETERMINISTIC


BEGIN

    DECLARE nombre_completo VARCHAR(60);

    SELECT CONCAT(fname, ' ', lname)
    INTO nombre_completo
    FROM employee
    WHERE emp_id = p_emp_id;

    RETURN ifnull(nombre_completo,'Empleado no encontrado');

END $$

DELIMITER ;

SELECT obtener_nombre_empleado(1) AS Nombre_Empleado;
SELECT obtener_nombre_empleado(10);

-- 3 - Crear un procedimiento almacenado llamado "obtener_promedio" que tome como parámetro de entrada el nombre de
-- un curso y calcule el promedio de las calificaciones de todos los alumnos inscriptos en ese curso. Verificar mediante ejecución del procedimiento.

-- Creamos la tabla de cursos
CREATE TABLE IF NOT EXISTS cursos (
    curso_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL
);

-- Creamos la tabla de alumnos
CREATE TABLE IF NOT EXISTS alumnos (
    alumno_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50)
);

-- Creamos la tabla intermedia con las calificaciones de las inscripciones
CREATE TABLE IF NOT EXISTS inscripciones (
    inscripcion_id INT AUTO_INCREMENT PRIMARY KEY,
    alumno_id INT,
    curso_id INT,
    calificacion DECIMAL(4,2),
    FOREIGN KEY (alumno_id) REFERENCES alumnos(alumno_id),
    FOREIGN KEY (curso_id) REFERENCES cursos(curso_id)
);

-- Insertamos algunos datos de prueba para poder verificar el procedimiento
INSERT INTO cursos (nombre_curso) VALUES ('Bases de Datos I'), ('Programación Web');
INSERT INTO alumnos (nombre, apellido) VALUES ('Ana', 'Gomez'), ('Juan', 'Perez'), ('Maria', 'Lopez');

-- Calificaciones para "Bases de Datos I" (ID: 1)
INSERT INTO inscripciones (alumno_id, curso_id, calificacion) VALUES 
(1, 1, 8.50), -- Ana se sacó un 8.5
(2, 1, 9.00), -- Juan se sacó un 9.0
(3, 1, 6.50); -- Maria se sacó un 6.5

-- Creamos el procedimiento 
DELIMITER $$

CREATE PROCEDURE obtener_promedio(
    IN p_nombre_curso VARCHAR(100)
)
BEGIN
    DECLARE promedio DECIMAL(4,2);

    -- Calculamos el promedio de calificaciones para el curso indicado
    SELECT AVG(i.calificacion)
    INTO promedio
    FROM inscripciones i
    INNER JOIN cursos c ON i.curso_id = c.curso_id
    WHERE c.nombre_curso = p_nombre_curso;

    -- Mostramos el resultado en pantalla de manera prolija
    IF promedio IS NOT NULL THEN
        SELECT p_nombre_curso AS Curso, promedio AS Promedio_Calificaciones;
    ELSE
        SELECT CONCAT('No se encontraron calificaciones para el curso: ', p_nombre_curso) AS Error;
    END IF;
END $$

DELIMITER ;

-- Debería calcular el promedio de (8.5 + 9.0 + 6.5) / 3 = 8.00
CALL obtener_promedio('Bases de Datos I');

-- Prueba con un curso que no tiene notas o no existe
CALL obtener_promedio('Cocina Inicial');


-- 4 - Crear un procedimiento almacenado "actualizar_stock" que tome como parámetros de entrada el código del producto y la cantidad a agregar al stock actual. 
-- El procedimiento debe actualizar el stock sumando la cantidad especificada al stock actual del producto correspondiente. Verificar mediante ejecución del procedimiento.


DROP PROCEDURE IF EXISTS actualizar_stock;

DELIMITER $$

CREATE PROCEDURE actualizar_stock(
     IN p_title_id VARCHAR(6),
     IN p_cantidad_agregar INT
)
BEGIN
  
     IF EXISTS (SELECT 1 FROM titles WHERE title_id = p_title_id) THEN
         
         -- 2. Actualizamos sumando la cantidad al stock acumulado (ytd_sales)
         UPDATE titles
         SET ytd_sales = IFNULL(ytd_sales, 0) + p_cantidad_agregar
         WHERE title_id = p_title_id;
         
         -- 3. Mostramos una consulta con el resultado final para verificar el cambio
         -- CORREGIDO: Cambiamos [Stock Actualizado] por 'Stock Actualizado'
         SELECT title_id AS Codigo, title AS Titulo, ytd_sales AS 'Stock Actualizado'
         FROM titles
         WHERE title_id = p_title_id;
         
     ELSE
         -- Si no existe, devolvemos un mensaje de error limpio
         SELECT 'Error: El código de libro especificado no existe.' AS Mensaje_Error;
     END IF;
END $$

DELIMITER ;

-- 5 - Crear una vista que muestre el título, el autor, el precio y la editorial de todos 
-- los libros de cocina de la base pubs.

CREATE OR REPLACE VIEW vista_libros_cocina AS
SELECT
    t.title AS Titulo,
    IFNULL(CONCAT(a.au_fname,' ',a.au_lname),'Sin autor') AS Autor,
    t.price AS Precio,
    p.pub_name AS Editorial
FROM titles t
LEFT JOIN titleauthor ta
    ON t.title_id = ta.title_id
LEFT JOIN authors a
    ON ta.au_id = a.au_id
LEFT JOIN publishers p
    ON t.pub_id = p.pub_id
WHERE t.type IN ('mod_cook','trad_cook');

SELECT * FROM vista_libros_cocina;

/*6 – Dadas las siguientes tablas:
CREATE TABLE fabricantes (
    id_fabricante INT PRIMARY KEY,
    nombre_fabricante VARCHAR(255) NOT NULL
);

INSERT INTO fabricantes (id_fabricante, nombre_fabricante)
VALUES(1, 'Fabricante A'),(2, 'Fabricante B'),(3, 'Fabricante C');

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    id_fabricante INT,
    nombre_producto VARCHAR(255) NOT NULL,
    fecha_lanzamiento DATE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante)
);

INSERT INTO productos (id_producto, id_fabricante, nombre_producto, fecha_lanzamiento)
VALUES(1, 1, 'Producto X', '2020-01-01'),(2, 2, 'Producto Y', '2019-12-01'), (3, 3, 'Producto Z', '2021-05-15'); 

 a) Crear un índice compuesto en las columnas id_fabricante y nombre_producto de la tabla productos.
 b) Crear un índice único en la columna id_producto de la tabla productos.
 c) Modificar el índice idx_productos_id_fabricante_nombre para que sea  único en la columna id_fabricante.
 d) Crear un nuevo índice único en la columna id_fabricante
 e) Eliminar el índice idx_productos_id_fabricante de la tabla productos
*/

CREATE DATABASE ejercicio6_indices;
USE ejercicio6_indices;

CREATE TABLE fabricantes (
    id_fabricante INT PRIMARY KEY,
    nombre_fabricante VARCHAR(255) NOT NULL
);

INSERT INTO fabricantes (id_fabricante, nombre_fabricante)
VALUES(1, 'Fabricante A'),(2, 'Fabricante B'),(3, 'Fabricante C');

CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    id_fabricante INT,
    nombre_producto VARCHAR(255) NOT NULL,
    fecha_lanzamiento DATE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante)
);

INSERT INTO productos (id_producto, id_fabricante, nombre_producto, fecha_lanzamiento)
VALUES(1, 1, 'Producto X', '2020-01-01'),(2, 2, 'Producto Y', '2019-12-01'), (3, 3, 'Producto Z', '2021-05-15'); 

CREATE INDEX idx_productos_id_fabricante_nombre
ON productos (id_fabricante, nombre_producto);

SHOW INDEX FROM productos;

-- id_producto ya es PRIMARY KEY, por lo tanto
-- ya posee un índice único automáticamente.

--  b) Crear un índice único en la columna id_producto de la tabla productos.
CREATE UNIQUE INDEX idx_productos_id_producto
ON productos (id_producto);

-- c) Modificar el índice idx_productos_id_fabricante_nombre para que sea  único en la columna id_fabricante.
ALTER TABLE productos
DROP INDEX idx_productos_id_fabricante_nombre,
ADD UNIQUE INDEX idx_productos_id_fabricante (id_fabricante);

-- Verificar

SHOW INDEX FROM productos;

-- d) Crear un nuevo índice único en la columna id_fabricante

CREATE UNIQUE INDEX idx_productos_id_fabricante
ON productos(id_fabricante);

-- e) Eliminar el índice idx_productos_id_fabricante de la tabla productos
DROP INDEX idx_productos_id_fabricante
ON productos;

SHOW INDEX FROM productos;

/*7 -  Se desea modificar un sistema de gestión de empleados para incluir  un mecanismo automático que transfiera a los empleados que cumplen con ciertos criterios de jubilación a una tabla especializada llamada jubilados. 
 Los criterios de jubilación son: los empleados deben tener 30 años o más de antigüedad y 65 años o más de edad. Además, se requiere que cualquier inserción en la tabla empleados que cumpla con estos criterios resulte en una inserción automática en la tabla jubilados.

CREATE TABLE empleados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);

CREATE TABLE jubilados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);
*/

CREATE DATABASE ejercicio7_jubilacion;
USE ejercicio7_jubilacion;

CREATE TABLE empleados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);

CREATE TABLE jubilados (
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  antiguedad INT NOT NULL
);

DELIMITER $$

CREATE TRIGGER trg_jubilacion
AFTER INSERT
ON empleados
FOR EACH ROW
BEGIN

    IF NEW.edad >= 65
       AND NEW.antiguedad >= 30 THEN

        INSERT INTO jubilados(nombre, edad, antiguedad)
        VALUES(
            NEW.nombre,
            NEW.edad,
            NEW.antiguedad
        );

    END IF;

END$$

DELIMITER ;

INSERT INTO empleados
VALUES('Carlos',66,35);

INSERT INTO empleados
VALUES('Juan',40,15);

SELECT * FROM jubilados;
SELECT * FROM empleados;



/*
8 - Crear un procedimiento almacenado llamado ActualizarEmpleados que tome dos  parámetros de entrada:

codigo_empleado (VARCHAR, 10): El identificador del empleado a actualizar.

salario_actualizado (DECIMAL): El nuevo salario del empleado.

En el procedimiento, utilizar una transacción para realizar la actualización del salario del empleado:
Obtener la información actual del empleado especificado.
Verificar si el nuevo salario es válido (no puede ser menor que el salario actual).
Si el salario es válido, realiza la actualización del salario del empleado.
Si el salario actualizado sería menor que el salario actual, muestra un mensaje al usuario indicando que la operación se cancela y realiza un rollback.

Llamar al procedimiento ActualizarEmpleados con diferentes valores de codigo_empleado y salario_actualizado, incluyendo casos donde el salario actualizado sería menor que el salario actual.
Verificar que el procedimiento funcione correctamente y que se muestren mensajes de error y se realice un rollback cuando corresponda.

*/

CREATE DATABASE ejercicio8;
USE ejercicio8;

CREATE TABLE empleados (
    codigo_empleado VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50),
    salario DECIMAL(10,2)
);

INSERT INTO empleados VALUES
('E001','Juan Perez',50000),
('E002','Ana Gomez',65000),
('E003','Carlos Lopez',80000);

DELIMITER $$

CREATE PROCEDURE ActualizarEmpleados(
    IN p_codigo_empleado VARCHAR(10),
	IN p_salario_actualizado DECIMAL(10,2)
)
BEGIN
    DECLARE salario_actual DECIMAL(10,2);

    START TRANSACTION;

   
    SELECT salario
    INTO salario_actual
    FROM empleados
	WHERE codigo_empleado = p_codigo_empleado;

 IF p_salario_actualizado < salario_actual THEN
    ROLLBACK;
    SELECT 'El salario actualizado es menor que el salario actual. Operación cancelada.' AS mensaje;
ELSE
    UPDATE empleados
    SET salario = p_salario_actualizado
    WHERE codigo_empleado = p_codigo_empleado;

    COMMIT;

    SELECT 'Salario actualizado correctamente.' AS mensaje;
END IF;

END$$
DELIMITER ;

CALL ActualizarEmpleados('E001',60000);
CALL ActualizarEmpleados('E002',50000);

SELECT * FROM empleados;

/*
9 - Gestión de Usuarios

a) Crear un usuario sin privilegios específicos
b) Crear un usuario con privilegios de lectura sobre la base pubs
c) Crear un usuario con privilegios de escritura sobre la base pubs
d) Crear un usuario con todos los privilegios sobre la base pubs
e) Crear un usuario con privilegios de lectura sobre la tabla titles
f) Eliminar al usuario que tiene todos los privilegios sobre la base pubs
g) Eliminar a dos usuarios a la vez
h) Eliminar un usuario y sus privilegios asociados
i) Revisar los privilegios de un usuario

*/
USE pubs;

-- a) Crear un usuario sin privilegios específicos
CREATE USER 'yamila'@'localhost' IDENTIFIED BY 'clave123';

-- b) Crear un usuario con privilegios de lectura sobre la base pubs
CREATE USER 'daniel_lectura'@'localhost' IDENTIFIED BY 'clave123';

GRANT SELECT
ON pubs.*
TO 'daniel_lectura'@'localhost';

-- c) Crear un usuario con privilegios de escritura sobre la base pubs
CREATE USER 'jorge_escritura'@'localhost' IDENTIFIED BY 'clave123';

GRANT INSERT, UPDATE, DELETE
ON pubs.*
TO 'jorge_escritura'@'localhost';

-- d) Crear un usuario con todos los privilegios sobre la base pubs
CREATE USER 'francisco_admin'@'localhost' IDENTIFIED BY 'clave123';

GRANT ALL PRIVILEGES
ON pubs.*
TO 'francisco_admin'@'localhost';

-- e) Crear un usuario con privilegios de lectura sobre la tabla titles
CREATE USER 'luciana_titles'@'localhost' IDENTIFIED BY 'clave123';

GRANT SELECT
ON pubs.titles
TO 'luciana_titles'@'localhost';


-- f) Eliminar al usuario que tiene todos los privilegios sobre la base pubs
DROP USER 'francisco_admin'@'localhost';

-- g) Eliminar dos usuarios a la vez
DROP USER
'yamila'@'localhost',
'luciana_titles'@'localhost';

-- h) Eliminar un usuario y sus privilegios asociados
DROP USER 'jorge_escritura'@'localhost';

-- i) Revisar los privilegios de un usuario
SHOW GRANTS FOR 'daniel_lectura'@'localhost';

--  10 – Gestor Mongo DB

/* 11 - A partir de la siguiente especificación deberá recolectar datos para poder diseñar una Base de Datos.

a) Determinar las entidades relevantes al Sistema.
Pieza 
Operario
m:n
toa -> Ficha

Pieza
Importador
m:n
toa -> Factura

Pieza
Televisor
m:n
toa -> Mapa


b) Determinar los atributos de cada entidad.


Pieza:
	- id_pieza (pk)
	- nombre
	- descripción

Operario:
	- id_operario (pk)
	- nombre
	- apellido
	- dni
	- fecha_ingreso

Importador:
	- id_importador (pk)
	- nombre_empresa
	- telefono
	- email

Televisor:
	- id_televisor
	- marca
	- modelo

Ficha :
-	id_ficha (pk)
-	id_pieza (fk)
-	id_operario (fk)
-	fecha
-	cantidad

Factura:
	- id_factura (pk)
	- id_pieza (fk)
	- id_importador (fk)
	- fecha
	- cantidad
	- precio_unitario

Mapa:
	- id_mapa (pk)
	- id_pieza (fk)
	- id_televisor (fk)
	- orden_ensamblado
	- posición
	- cantidad

c) Confeccionar el Diagrama de Entidad Relación (DER), junto al Diccionario de Datos

d) Realizar el Diagrama de Tablas e implementar en código SQL (puede utilizar cualquier Gestor) la Base de Datos.*/

create database Fabrica_televisores;
use Fabrica_Televisores;
-- -----------------------------------------------------
-- Table piezas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS piezas (
  id_pieza INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(100) NULL,
  PRIMARY KEY (id_pieza)
  );


-- -----------------------------------------------------
-- Table operarios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS operarios (
  id_operario INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  dni CHAR(8) NOT NULL,
  fecha_ingreso DATE NOT NULL,
  PRIMARY KEY (id_operario),
  constraint uq_dni unique(dni)
);


-- -----------------------------------------------------
-- Table importadores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS importadores (
  id_importador INT NOT NULL AUTO_INCREMENT,
  nombre_empresa VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(45) NOT NULL,
  PRIMARY KEY (id_importador)
  );


-- -----------------------------------------------------
-- Table televisores
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS televisores (
  id_televisor INT NOT NULL AUTO_INCREMENT,
  marca VARCHAR(45) NOT NULL,
  modelo VARCHAR(45) NOT NULL,
  PRIMARY KEY (id_televisor)
  );


-- -----------------------------------------------------
-- Table facturas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS facturas (
  id_factura INT NOT NULL AUTO_INCREMENT,
  id_importador INT NOT NULL,
  id_pieza INT NOT NULL,
  fecha DATETIME NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_factura),
  CONSTRAINT fk_importadores_has_piezas_importadores
    FOREIGN KEY (id_importador)
    REFERENCES importadores (id_importador)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT fk_importadores_has_piezas_piezas1
    FOREIGN KEY (id_pieza)
    REFERENCES piezas (id_pieza)
    ON DELETE cascade
    ON UPDATE cascade
    );


-- -----------------------------------------------------
-- Table fichas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fichas (
  id_ficha INT NOT NULL AUTO_INCREMENT,
  id_operario INT NOT NULL,
  id_pieza INT NOT NULL,
  fecha DATE NOT NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (id_ficha),
  CONSTRAINT fk_operarios_has_piezas_operarios1
    FOREIGN KEY (id_operario)
    REFERENCES operarios (id_operario)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT fk_operarios_has_piezas_piezas1
    FOREIGN KEY (id_pieza)
    REFERENCES piezas (id_pieza)
    ON DELETE cascade
    ON UPDATE cascade
    );


-- -----------------------------------------------------
-- Table mapas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS mapas (
  id_mapa INT NOT NULL AUTO_INCREMENT,
  id_televisor INT NOT NULL,
  id_pieza INT NOT NULL,
  posicion VARCHAR(100) NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (id_mapa),
  CONSTRAINT fk_televisores_has_piezas_televisores1
    FOREIGN KEY (id_televisor)
    REFERENCES televisores (id_televisor)
    ON DELETE cascade
    ON UPDATE cascade,
  CONSTRAINT fk_televisores_has_piezas_piezas1
    FOREIGN KEY (id_pieza)
    REFERENCES piezas (id_pieza)
    ON DELETE cascade
    ON UPDATE cascade
    );
    
    --------------------------------------------------------------------------------------------------
INSERT INTO piezas (nombre, descripcion) VALUES
('Pantalla LED', 'Pantalla principal del televisor'),
('Placa madre', 'Controla el funcionamiento general'),
('Fuente de poder', 'Suministro de energia'),
('Parlantes', 'Salida de audio'),
('Control remoto', 'Dispositivo de control');

INSERT INTO operarios (nombre, apellido, dni, fecha_ingreso) VALUES
('Juan', 'Perez', '12345678', '2020-01-10'),
('Maria', 'Gomez', '23456789', '2019-03-15'),
('Carlos', 'Lopez', '34567890', '2021-07-20'),
('Ana', 'Martinez', '45678901', '2018-11-05'),
('Luis', 'Fernandez', '56789012', '2022-02-01');

INSERT INTO importadores (nombre_empresa, telefono, email) VALUES
('TechImport SA', '111111111', 'contacto@techimport.com'),
('GlobalParts', '222222222', 'info@globalparts.com'),
('Electronica Sur', '333333333', 'ventas@electrosur.com'),
('Importadora Norte', '444444444', 'norte@import.com'),
('Distribuciones LATAM', '555555555', 'latam@dist.com');

INSERT INTO televisores (marca, modelo) VALUES
('Samsung', 'A100'),
('LG', 'B200'),
('Sony', 'X300'),
('Philips', 'P400'),
('TCL', 'T500');

INSERT INTO facturas 
(id_importador, id_pieza, fecha, cantidad, precio_unitario) 
VALUES
(1, 1, '2024-01-10 10:00:00', 10, 15000.50),
(2, 2, '2024-02-12 12:30:00', 5, 20000.00),
(3, 3, '2024-03-05 09:15:00', 8, 12000.75),
(4, 4, '2024-04-18 14:45:00', 15, 5000.25),
(5, 5, '2024-05-20 16:20:00', 20, 3000.00);

INSERT INTO fichas (id_operario, id_pieza, fecha, cantidad) VALUES
(1, 1, '2024-01-11', 2),
(2, 2, '2024-01-12', 1),
(3, 3, '2024-01-13', 3),
(4, 4, '2024-01-14', 4),
(5, 5, '2024-01-15', 2);

INSERT INTO mapas (id_televisor, id_pieza, posicion, cantidad) VALUES
(1, 1, 'Frontal', 1),
(1, 2, 'Interno', 1),
(2, 3, 'Posterior', 1),
(3, 4, 'Laterales', 2),
(4, 5, 'Externo', 1);


-- Ver qué operario trabajó en qué pieza
SELECT 	o.nombre,
		p.nombre AS pieza,
		f.cantidad
FROM 	fichas f
JOIN	operarios o ON f.id_operario = o.id_operario
JOIN 	piezas p ON f.id_pieza = p.id_pieza;

-- Ver todos los televisores aunque no tengan piezas asignadas

SELECT 	t.marca,
		t.modelo,
		m.posicion,
		m.cantidad
FROM televisores t
LEFT JOIN mapas m ON t.id_televisor = m.id_televisor;



-- e) Crear al menos 2 consultas relacionadas para poder probar la Base de Datos.

-- Consulta 1:
-- Mostrar los componentes utilizados en cada modelo de televisor

SELECT 
    t.marca,
    t.modelo,
    p.nombre AS pieza,
    m.posicion,
    m.cantidad
FROM televisores t
INNER JOIN mapas m 
    ON t.id_televisor = m.id_televisor
INNER JOIN piezas p 
    ON m.id_pieza = p.id_pieza
ORDER BY t.modelo;

 -- Consulta 2:
-- Mostrar piezas fabricadas por cada operario

SELECT
    o.nombre,
    o.apellido,
    p.nombre AS pieza_fabricada,
    f.fecha,
    f.cantidad
FROM operarios o
INNER JOIN fichas f
    ON o.id_operario = f.id_operario
INNER JOIN piezas p
    ON f.id_pieza = p.id_pieza
ORDER BY o.apellido;
    
/* Esta empresa se encuentra ubicada en Hong Kong y se dedica a la fabricación de Smart TV.

Las componentes de los TV pueden ser comprados a un importador, en tal caso la compra viene acompañada de una orden, otros componentes son fabricados en la empresa, para lo cual esos componentes tienen asignado un empleado que se dedica exclusivamente a un tipo de componente, aunque un componente puede ser fabricado por más de un empleado, el empleado completa una hoja de trabajo con la cantidad fabricada y la fecha.

Los diferentes modelos de Smart TV tienen de 275 a 430 componentes, aunque un componente puede estar incorporado en más de un TV, existe un mapa de armado para cada modelo de TV donde se indica la ubicación y el orden de los componentes.

*/

