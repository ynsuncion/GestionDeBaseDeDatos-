create database editoriales;

USE editoriales;

CREATE TABLE editoriales (
    id_editorial INT NOT NULL,
    nombre_editorial VARCHAR(100) NOT NULL
);

-- Agregar clave primaria
ALTER TABLE editoriales
ADD PRIMARY KEY (id_editorial);


CREATE TABLE empleados (
    id_empleado INT NOT NULL,
    nombre_empleado VARCHAR(100) NOT NULL,
    id_editorial INT NOT NULL
);

-- Agregar clave primaria
ALTER TABLE empleados
ADD PRIMARY KEY (id_empleado);

-- Agregar clave foránea
ALTER TABLE empleados
ADD CONSTRAINT fk_empleados_editoriales
FOREIGN KEY (id_editorial)
REFERENCES editoriales(id_editorial)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE libros (
    id_libro INT NOT NULL,
    titulo_libro VARCHAR(150) NOT NULL,
    id_editorial INT NOT NULL
);

-- Agregar clave primaria
ALTER TABLE libros
ADD PRIMARY KEY (id_libro);

-- Agregar clave foránea
ALTER TABLE libros
ADD CONSTRAINT fk_libros_editoriales
FOREIGN KEY (id_editorial)
REFERENCES editoriales(id_editorial)
ON DELETE CASCADE
ON UPDATE CASCADE;

INSERT INTO editoriales (id_editorial, nombre_editorial)
VALUES
    (1, 'Editorial Planeta'),
    (2, 'Editorial Santillana'),
    (3, 'Editorial Anaya'),
    (4, 'Editorial Alfaguara'),
    (5, 'Editorial SM'),
    (6, 'Editorial Fondo de Cultura Económica'),
    (7, 'Editorial Siglo XXI'),
    (8, 'Editorial Cátedra'),
    (9, 'Editorial Tecnos'),
    (10, 'Editorial Ariel');

INSERT INTO empleados (id_empleado, nombre_empleado, id_editorial)
VALUES
    (1, 'Juan Pérez', 1),
    (2, 'María Rodríguez', 1),
    (3, 'Pedro López', 2),
    (4, 'Ana Martínez', 2),
    (5, 'Carlos García', 3),
    (6, 'Laura González', 3),
    (7, 'Luis Fernández', 4),
    (8, 'Elena Sánchez', 4),
    (9, 'Javier Ruiz', 5),
    (10, 'Sofía Torres', 5);

INSERT INTO libros (id_libro, titulo_libro, id_editorial)
VALUES
    (1, 'Cien años de soledad', 1),
    (2, 'Don Quijote de la Mancha', 1),
    (3, 'La sombra del viento', 2),
    (4, 'Rayuela', 2),
    (5, 'Crónica de una muerte anunciada', 3),
    (6, 'Los detectives salvajes', 3),
    (7, 'Ficciones', 4),
    (8, 'La casa de los espíritus', 4),
    (9, 'La ciudad y los perros', 5),
    (10, 'Cien años de soledad', 5);

-- =========================
-- Consultas para verificar
-- =========================
select * from editoriales;
select * from libros;
select * from empleados; 


-- Ejercicios sobre integridad referencial:
-- 1.	Eliminar una editorial: Si se elimina una editorial de la tabla editoriales, 
-- ¿qué sucede con los libros asociados? Escriba una consulta SQL que elimine una editorial y
-- sus libros relacionados.

DELETE FROM editoriales
WHERE id_editorial = 1;

-- Si borro la editorial se borran los libro asociados 

/* 2.  Actualizar el nombre de una editorial: Si se actualiza el nombre
 de una editorial en la tabla editoriales, ¿qué sucede con los libros 
 relacionados?
*/

update editoriales
set nombre_editorial = 'Nombre de la editorial'
where id_editorial = 4

-- al actualizar no cambia en nada libros 

/*3.Eliminar un empleado: Si se elimina un empleado de la tabla empleados, 
¿qué sucede con los libros relacionados con esa editorial?
*/

delete from empleados
WHERE id_empleado = 9;

-- No sucede nada con los libros 

/* 4.	Actualizar el nombre de un empleado: Si se actualiza el nombre de un empleado
 en la tabla empleados, ¿qué sucede con los libros relacionados con esa editorial? 
*/

update empleados
set nombre_empleado = 'Yamila Suncion'
where id_empleado = 8

-- no sucede nada con la editorial 

/* 5.	Eliminar un libro: Si se elimina un libro de la tabla libros, 
¿qué sucede con la relación con la editorial?*/


DELETE FROM libros
WHERE id_libro = 5;

-- No suede nada en editorial

/* 6.	Cambiar la editorial de un libro: Si se cambia la editorial a la 
que está asociado un libro en la tabla libros, ¿qué sucede con la relación 
con la editorial anterior?
*/
UPDATE libros
SET id_editorial = 3
WHERE id_libro = 7;

-- no sucede nada con la editorial anterior 

/* 7.	Eliminar una editorial con empleados: Si se intenta eliminar una editorial 
que tiene empleados asociados, ¿qué sucede?*/

delete from editoriales 
where id_editorial = 3

-- se eliminan tambien los empleados de esa editorial 

/* 8.	Eliminar un empleado con libros: Si se intenta eliminar un empleado que
 tiene libros asociados, ¿qué sucede? */
 
 delete from empleados 
where id_empleado =  3

-- No sucede nada porque no se relacionan 

/* 9.	Eliminar una editorial y sus empleados: ¿Cómo se eliminaría una editorial
 y todos sus empleados?*/

delete from editoriales 
where id_editorial = 4

-- Porque estan enlazados mediante cascade 

/* 10.	Eliminar una editorial y transferir sus empleados a otra editorial:
 ¿Cómo se eliminaría una editorial y reasignaría a sus empleados a otra editorial?*/

UPDATE empleados
SET id_editorial = 2
WHERE id_editorial = 3;


DELETE FROM editoriales
WHERE id_editorial = 3;