/*TP  Vistas
Ejercicio 1: Crea una vista que muestre el título, el autor, 
el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, 
tipo de libro, año de publicación y mes de publicación.
*/ 
	USE pubs;

CREATE VIEW vista_titulo1 AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(aut.au_fname, ' ', aut.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    MONTH(ti.pubdate) AS mes_publicacion,
    SUM(s.qty) AS cantidad_vendida

FROM stores st

JOIN sales s 
    ON st.stor_id = s.stor_id

JOIN titles ti
    ON s.title_id = ti.title_id 

JOIN titleauthor tia
    ON ti.title_id = tia.title_id 

JOIN authors aut
    ON aut.au_id = tia.au_id

GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate),
    MONTH(ti.pubdate);

select * from vista_titulo1;


/*Ejercicio 2: Crea una vista que muestre el título, el autor, el precio y
 la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de
 libro y año de publicación, pero solo para las ventas que superaron los 10 libros*/
 
 CREATE VIEW titulo1 AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(aut.au_fname, ' ', aut.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    SUM(s.qty) AS cantidad_vendida

FROM stores st 

JOIN sales s 
    ON st.stor_id = s.stor_id

JOIN titles ti
    ON s.title_id = ti.title_id 

JOIN titleauthor tia
    ON ti.title_id = tia.title_id 

JOIN authors aut
    ON aut.au_id = tia.au_id    

WHERE s.qty > 10 

GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
    select*from titulo1;
   
/*Ejercicio 3: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de
 la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron en el año 1990.
*/
    
CREATE VIEW vistaVentas AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(aut.au_fname, ' ', aut.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    SUM(s.qty) AS cantidad_vendida

FROM stores st

JOIN sales s 
    ON st.stor_id = s.stor_id

JOIN titles ti
    ON s.title_id = ti.title_id 

JOIN titleauthor tia
    ON ti.title_id = tia.title_id 

JOIN authors aut
    ON aut.au_id = tia.au_id    

WHERE YEAR(s.ord_date) = 1990

GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
    select * from vistaVentas;
    
-- Ejercicio 4: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, 
-- tipo de libro y año de publicación, pero solo para las ventas que se realizaron entre 1990 y 1994.
CREATE VIEW vista_ventas_1990_1994 AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(aut.au_fname, ' ', aut.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    SUM(s.qty) AS cantidad_vendida

FROM stores st

JOIN sales s 
    ON st.stor_id = s.stor_id

JOIN titles ti
    ON s.title_id = ti.title_id 

JOIN titleauthor tia
    ON ti.title_id = tia.title_id 

JOIN authors aut
    ON aut.au_id = tia.au_id    

WHERE YEAR(s.ord_date) BETWEEN 1990 AND 1994

GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
    select * from vista_ventas_1990_1994;
    
-- Ejercicio 5: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos
-- los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se
-- realizaron en la tienda con el ID 7066.

 CREATE VIEW vista_tienda_7066 AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(aut.au_fname, ' ', aut.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    SUM(s.qty) AS cantidad_vendida

FROM stores st

JOIN sales s 
    ON st.stor_id = s.stor_id

JOIN titles ti
    ON s.title_id = ti.title_id 

JOIN titleauthor tia
    ON ti.title_id = tia.title_id 

JOIN authors aut
    ON aut.au_id = tia.au_id    

WHERE st.stor_id = '7066'

GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
select * from vista_tienda_7066;

-- Ejercicio 6: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos
-- los libros de la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que
-- se realizaron por el autor con el ID 172.

CREATE VIEW muestraVista AS
SELECT 
    st.stor_name AS tienda,
    ti.title AS titulo,
    CONCAT(a.au_fname, ' ', a.au_lname) AS autor,
    ti.price AS precio,
    ti.type AS tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    SUM(sl.qty) AS cantidad_vendida

FROM titles ti 

JOIN titleauthor ta
    ON ti.title_id = ta.title_id

JOIN authors a
    ON ta.au_id = a.au_id

JOIN sales sl
    ON ti.title_id = sl.title_id 

JOIN stores st
    ON sl.stor_id = st.stor_id

WHERE a.au_id LIKE '172%'

GROUP BY
    st.stor_name,
    ti.title,
    a.au_fname,
    a.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
select * from muestraVista;

-- Actualización de datos en tablas mediante la actualización de vistas:

-- Ejercicio 7: Crea una vista que permita actualizar el precio de un libro en la tabla titles.
CREATE VIEW actualizacionPrecio AS
SELECT title_id , title, price
FROM titles;

update actualizacionPrecio 
set price = 3000
where title_id = 1;

select* from titles;


-- Ejercicio 8: Crea una vista que permita actualizar el nombre de un autor en la tabla authors.

CREATE VIEW actualizacionAutor AS
SELECT au_id, au_fname, au_lname
FROM authors;

set SQL_SAFE_UPDATES = 0;

UPDATE actualizacionAutor
set au_fname = 'Yamila' , au_lname = 'suncion'
where au_id = 409;

select * from authors;

-- Ejercicio 9: Crea una vista que permita actualizar la cantidad vendida de un libro en la tabla sales.
CREATE VIEW actualizacionAutor2 AS
SELECT stor_id,title_id, qty
FROM sales;

UPDATE actualizacionAutor2
set  qty = 7
where stor_id= 6380 and title_id = 3;

select * from sales;


 -- Ejercicio 10: Crea una vista que permita actualizar la fecha de publicación de un
 -- libro en la tabla titles.

CREATE VIEW actualizacionFecha1 AS
SELECT title_id, title,pubdate 
FROM titles;

UPDATE actualizacionFecha1
set  pubdate = '2000-05-08' 
where title_id = 1;

select * from titles;

    
    
    