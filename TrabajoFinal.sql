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
    p_emp_id CHAR(9)
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
-- os libros de cocina de la base pubs.
