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

/* 10 – Gestor Mongo DB

a) Activar la base de datos "local" y luego imprimir las colecciones existentes.
b) Activar la base de datos "test" y luego imprimir las colecciones existentes.
c) Activar la base de datos "baseEjemplo2".
d) Mostrar las colecciones existentes en la base de datos "baseEjemplo2".
e) Crear otra colección llamada usuarios donde almacenar dos documentos con los 
campos nombre y clave.
f) Mostrar nuevamente las colecciones existentes en la base de datos "baseEjemplo2".

En la base pubs:
g) Insertar 2 documentos en la colección clientes con '_id' no repetidos
h) Intentar insertar otro documento con clave repetida.
i) Mostrar todos los documentos de la colección libros.

j) Crear una base de datos llamada "blog".
k) Agregar una colección llamada "posts" e insertar 1 documento con una estructura a 
su elección.
l) Mostrar todas las bases de datos actuales.
m) Eliminar la colección "posts"
n) Eliminar la base de datos "blog" y mostrar las bases de datos existentes.
*/