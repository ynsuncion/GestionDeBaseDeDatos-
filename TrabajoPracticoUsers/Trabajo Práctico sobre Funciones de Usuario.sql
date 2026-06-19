-- Trabajo Práctico sobre Funciones de Usuario

-- Ejercicio 1: Crear una función para calcular la regalía total de cada autor.

DELIMITER //
drop function if exists fn_regaliaTotal //
create function fn_regaliaTotal (p_au_id INT) 
returns DECIMAL(15,2)
deterministic
reads sql data
begin
    declare total DECIMAL(15,2);

    select COALESCE( 
                    sum(t.price *(t.royalty / 100) * (ta.royaltyper /100) * t.ytd_sales), 0) 
    into total 
    from titleauthor ta
    join titles t on ta.title_id = t.title_id
    where ta.au_id = p_au_id
        and t.price is not NULL
        and t.ytd_sales is not NULL
        and t.royalty is not null;
    return total;
end //
delimiter; 

-- Ejercicio 2: Crear una función para obtener el precio máximo de cada tipo de libro.
use pubs;
delimiter//
drop FUNCTION if exists fn_precioMaximoPorLibro //
create function fn_precioMaximoPorLibro(categoria varchar(50))
returns decimal (15,2)
DETERMINISTIC
reads sql data
begin
    declare maxValor decimal(15,2);
    select max(price) 
    into maxValor
    from titles
    where type = categoria and price is not null; 
    return maxValor;
end //
delimiter;
select distinct type, fn_precioMaximoPorLibro(type) 
from titles 
where type <> '' and type is not null
order by type;
select distinct type from titles;

-- Ejercicio 3: Crear una función para calcular el ingreso (cantidad vendida multiplicada por el precio) de cada título.
 
 delimiter //
drop function if exists fn_ingresoPorTitulos//
create function fn_igresoPorTitulos(titulo varchar(100))
returns decimal(15,2)
DETERMINISTIC
reads sql data
begin
    declare total decimal(15,2);
    select coalesce(sum(t.price * s.qty),0)
    into  total
    from titles t
    left join sales s on t.title_id = s.title_id
    where t.title = titulo and t.price is not null ;
    return total;
end//
delimiter;

select t.title_id, t.title, fn_ingresoPorTitulos(t.title) 'Ingreso total'
from t.titles t
where t.title <> ''
group by t.title_id, t.title
order by 'Ingreso total' desc;

-- Ejercicio 4: Crear una función para obtener el nombre completo de un empleado a partir de su código.
use pubs;
delimiter //
drop function if exists fn_nombreCompletoEmpleado //
create function fn_nombreCompletoEmpleado(p_emp_id INT)
returns varchar(100)
DETERMINISTIC
reads sql data
begin
    declare nombreCompleto varchar(100);
    select concat(fname, ' ', lname) 
    into nombreCompleto
    from employee
    where emp_id = p_emp_id;

    return nombreCompleto;
end //
delimiter;

SELECT fn_nombreCompletoEmpleado(41) AS NombreCompleto;


-- Ejercicio 5: Crear una función para calcular el precio promedio de libros publicados de cada editorial.

delimiter //
drop function if exists fn_precioPromedioEditorial //   
create function fn_precioPromedioEditorial(p_pub_id varchar(4))
returns decimal(15,2)   
DETERMINISTIC
reads sql data
begin
    declare precioPromedio decimal(15,2);
    select avg(price) 
    into precioPromedio
    from titles
    where pub_id = p_pub_id and price is not null;
    return precioPromedio;
end //
delimiter;

SELECT pub_id, fn_precioPromedioEditorial(pub_id) AS PrecioPromedio
FROM titles
WHERE pub_id <> '' and pub_id is not null  
GROUP BY pub_id
ORDER BY PrecioPromedio DESC;