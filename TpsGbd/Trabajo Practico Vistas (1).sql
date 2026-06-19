-- Active: 1776992206856@@127.0.0.1@3307@pubs
-- TP  Vistas

use pubs;

-- Ejercicio 1: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro, año de publicación y mes de publicación.

create view v_libros_vendidos AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type, year(t.pubdate) 'Año de Publicacion', month(t.pubdate) 'Mes de publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate), month(t.pubdate);

select* from v_libros_vendidos;
drop view v_libros_vendidos;

-- Vistas que tienen condiciones con la cláusula WHERE:

-- Ejercicio 2: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que superaron los 10 libros.

create view v_libros_ventas_mayor_10 AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price Precio,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type Categoria, year(t.pubdate) 'Año de Publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
where s.qty > 10
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate);

select* from v_libros_ventas_mayor_10;
drop view v_libros_ventas_mayor_10;

-- Ejercicio 3: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron en el año 1990.

create view v_libros_ventas_año_1990 AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price Precio,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type Categoria, year(t.pubdate) 'Año de Publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
where year(t.pubdate) = 1990
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate);

select* from v_libros_ventas_año_1990;
drop view v_libros_ventas_año_1990;

-- Ejercicio 4: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron entre 1990 y 1994.

create view v_libros_ventas_entre_1990_1994 AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price Precio,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type Categoria, year(t.pubdate) 'Año de Publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
where year(t.pubdate) BETWEEN 1990 AND 1994
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate);

select* from v_libros_ventas_entre_1990_1994;
drop view v_libros_ventas_entre_1990_1994;

-- Ejercicio 5: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron en la tienda con el ID 7066.

--Tienda 7066 no tiene ventas, busco por la tienda 7067.
create view v_libros_ventas_tienda_7067 AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price Precio,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type Categoria, year(t.pubdate) 'Año de Publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
where st.stor_id = 7067
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate);

select* from v_libros_ventas_tienda_7067;
drop view v_libros_ventas_tienda_7067;

-- Ejercicio 6: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron por el autor con el ID 172.

create view v_libros_ventas_autor_172 AS
select t.title Titulo,concat (a.au_fname,' ',a.au_lname) 'Autor', t.price Precio,sum(s.qty) 'Cantidad vendida', st.stor_name 'Tienda', t.type Categoria, year(t.pubdate) 'Año de Publicacion'
from stores st
join sales s on st.stor_id = s.stor_id
join titles t on s.title_id = t.title_id
join titleauthor ta on t.title_id = ta.title_id
join authors a on ta.au_id = a.au_id
where a.au_id = 172
group by t.title, a.au_fname, a.au_lname, t.price, st.stor_name, t.type, year(t.pubdate);

select* from v_libros_ventas_autor_172;
drop view v_libros_ventas_autor_172;


-- Actualización de datos en tablas mediante la actualización de vistas:

-- Ejercicio 7: Crea una vista que permita actualizar el precio de un libro en la tabla titles.
create view v_actualizar_precio_libro AS
select title_id, title, price
from titles;

-- Actualizo el precio del libro con title_id 1 de(20 a 21)
update v_actualizar_precio_libro
set price = 21.00
where title_id = 1;

-- Ejercicio 8: Crea una vista que permita actualizar el nombre de un autor en la tabla authors.
create view v_actualizar_nombre_autor AS
select au_id, au_fname, au_lname
from authors;
drop VIEW v_actualizar_nombre_autor;

-- Actualizo el nombre del autor con au_id 172 de (Jhonson White a Jorge Sanchez)
update v_actualizar_nombre_autor
set au_fname = 'Jorge', au_lname = 'Sanchez'
where au_id = 172;

-- Ejercicio 9: Crea una vista que permita actualizar la cantidad vendida de un libro en la tabla sales.

create view v_actualizar_cantidad_vendida AS
select stor_id, title_id, qty
from sales;

-- Actualizo la cantidad vendida del libro con title_id 1 en la tienda con stor_id 7067 de (10 a 20)
update v_actualizar_cantidad_vendida
set qty = 20
where title_id = 1 and stor_id = 7067;


-- Ejercicio 10: Crea una vista que permita actualizar la fecha de publicación de un libro en la tabla titles.
create view v_actualizar_fecha_publicacion AS
select title_id, title, pubdate
from titles;

-- Actualizo la fecha de publicacion del libro con title_id 1 de (1990-09-00 a 1990-01-01)
update v_actualizar_fecha_publicacion
set pubdate = '1990-01-01'
where title_id = 1;
