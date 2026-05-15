/*TP  Vistas
Ejercicio 1: Crea una vista que muestre el título, el autor, 
el precio y la cantidad vendida de todos los libros de la tabla sales por cada tienda, 
tipo de libro, año de publicación y mes de publicación.
*/ 
use pubs 
create view vista_titulo2
as 
	select ti.title titulo, 
    aut.au_fname nombre, 
    ti.price precio,
    s.qty cantidad, 
    ti.type tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
    MONTH(ti.pubdate) AS mes_publicacion,
    SUM(s.qty) AS cantidad_vendida
    from stores st 
    join sales s 
    on st.stor_id = s.stor_id
    join titles ti
    on s.title_id = ti.title_id 
    join titleauthor tia
    on ti.title_id = tia.title_id 
    join authors aut
    on aut.au_id = tia.au_id    
    GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate),
    MONTH(ti.pubdate);

select * from vista_titulo2;

/*Ejercicio 2: Crea una vista que muestre el título, el autor, el precio y
 la cantidad vendida de todos los libros de la tabla sales por cada tienda, tipo de
 libro y año de publicación, pero solo para las ventas que superaron los 10 libros*/
 
 create view titulo2
 as 
	select ti.title titulo, 
    aut.au_fname nombre, 
    ti.price precio,
    s.qty cantidad, 
    ti.type tipo,
    YEAR(ti.pubdate) AS anio_publicacion,
   
    SUM(s.qty) AS cantidad_vendida
    from stores st 
    join sales s 
    on st.stor_id = s.stor_id
    join titles ti
    on s.title_id = ti.title_id 
    join titleauthor tia
    on ti.title_id = tia.title_id 
    join authors aut
    on aut.au_id = tia.au_id    
    
    WHERE s.qty>10 
    
    GROUP BY
    st.stor_name,
    ti.title,
    aut.au_fname,
    aut.au_lname,
    ti.price,
    ti.type,
    YEAR(ti.pubdate);
    
    select* from titulo2;
   
/*Ejercicio 3: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos los libros de
 la tabla sales por cada tienda, tipo de libro y año de publicación, pero solo para las ventas que se realizaron en el año 1990.
*/
    
    /*Ejercicio 3: Crea una vista que muestre el título, el autor, el precio y la cantidad vendida de todos 
    los libros de la tabla sales por cada tienda, 
    tipo de libro y año de publicación, pero solo para las ventas que se realizaron en el año 1990.
    */
    
    