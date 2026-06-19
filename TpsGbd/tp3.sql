-- Trabajo Practico sobre Índices

create database editoriales;
use editoriales;
CREATE TABLE editoriales (
    id_editorial INT PRIMARY KEY,
    nombre_editorial VARCHAR(255) NOT NULL
);

INSERT INTO editoriales (id_editorial, nombre_editorial)
VALUES
    (1, 'Editorial Santillana'),
    (2, 'Editorial Anagrama'),
    (3, 'Editorial Planeta'),
    (4, 'Editorial Alfaguara'),
    (5, 'Editorial SM'),
    (6, 'Editorial Penguin Random House'),
    (7, 'Editorial Norma'),
    (8, 'Editorial Ediciones B'),
    (9, 'Editorial Aguilar'),
    (10, 'Editorial Fondo de Cultura Económica');

CREATE TABLE libros (
    id_libro INT PRIMARY KEY,
    id_editorial INT,
    titulo VARCHAR(255) NOT NULL,
    fecha_publicacion DATE,
    FOREIGN KEY (id_editorial) REFERENCES editoriales(id_editorial)
);

INSERT INTO libros (id_libro, id_editorial, titulo, fecha_publicacion)
VALUES
    (1, 1, 'Cien años de soledad', '1967-05-30'),
    (2, 2, 'Rayuela', '1963-07-23'),
    (3, 3, 'La sombra del viento', '2001-04-27'),
    (4, 4, 'Pedro Páramo', '1955-11-30'),
    (5, 5, 'Don Quijote de la Mancha', '1605-01-16'),
    (6, 6, 'Harry Potter y la piedra filosofal', '1997-06-26'),
    (7, 7, 'Crimen y castigo', '1866-01-29'),
    (8, 8, 'Los detectives salvajes', '1998-09-01'),
    (9, 9, 'La casa de los espíritus', '1982-01-01'),
    (10, 10, 'Ficciones', '1944-05-01');

select * from editoriales;
select * from libros;

show index from editoriales;
show index from libros;

-- Ejercicio 1:
-- Crea un índice compuesto en las columnas id_editorial y titulo de la tabla libros.

create index idx_libros_id_editorial_titulo on libros(id_editorial, titulo);

-- Ejercicio 2:
-- Crea un índice en la columna fecha_publicacion de la tabla libros.

create index idx_fechaPublicacion on libros(fecha_publicacion);

-- Ejercicio 3:
-- Elimina el índice idx_libros_id_editorial_titulo de la tabla libros.

drop index idx_libros_id_editorial_titulo on libros;

-- Ejercicio 4:
-- Actualiza el índice idx_libros_id_editorial_titulo de la tabla libros para que sea un índice 
-- único en la columna id_editorial.

alter table libros 
drop index idx_libros_id_editorial_titulo,
add unique idx_libros_id_editorial(id_editorial);

-- Ejercicio 5: 
-- ¿Se puede usar alter para resolver el ejercicio anterior?

-- No, no se puede utilizar alter. 
 
-- Ejercicio 6:
-- Crea un índice único en la columna id_editorial de la tabla editoriales.

create unique index idx_editoriales_id_editorial on editoriales(id_editorial);

-- Ejercicio 7:
-- Crea un índice primary en la columna id_libro de la tabla libros.

alter table libros
drop primary key;

alter table libros
add primary key (id_libro);
