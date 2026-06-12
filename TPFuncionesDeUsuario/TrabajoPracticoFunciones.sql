
-- Ejercicio 1: Regalía total de cada autor
-- Fórmula: precio * (royalty/100) * (royaltyper/100) * ytd_sales
--   royalty     = % de regalía del libro (en titles)
--   royaltyper  = % que le corresponde a este autor (en titleauthor)
--   ytd_sales   = ventas anuales acumuladas
-- ============================================================

DELIMITER //
DROP FUNCTION IF EXISTS fn_regaliaTotal //
CREATE FUNCTION fn_regaliaTotal(p_au_id INT)
RETURNS DECIMAL(15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(15,2);

    SELECT COALESCE(
               SUM(t.price * (t.royalty / 100) * (ta.royaltyper / 100) * t.ytd_sales),
               0
           )
    INTO total
    FROM titleauthor ta
    INNER JOIN titles t ON ta.title_id = t.title_id
    WHERE ta.au_id    = p_au_id
      AND t.price     IS NOT NULL
      AND t.ytd_sales IS NOT NULL
      AND t.royalty   IS NOT NULL;

    RETURN total;
END //
DELIMITER ;
use pubs;

-- Ejemplo de uso: Regalía total por autor (solo autores con títulos)
SELECT
    a.au_id,
    CONCAT(a.au_fname, ' ', a.au_lname)   AS autor,
    fn_regaliaTotal(a.au_id)              AS regalia_total
FROM authors a
WHERE a.au_id IN (SELECT DISTINCT au_id FROM titleauthor)
ORDER BY regalia_total DESC;

-- ============================================================
-- Ejercicio 2: Precio máximo de un tipo de libro
-- Parámetro: tipo de libro (ej: 'business', 'psychology', ...)
-- ============================================================

DELIMITER //
DROP FUNCTION IF EXISTS fn_precioMaxTipo //
CREATE FUNCTION fn_precioMaxTipo(p_type CHAR(12))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE max_precio DECIMAL(10,2);

    SELECT MAX(price)
    INTO max_precio
    FROM titles
    WHERE type = p_type
      AND price IS NOT NULL;

    RETURN max_precio;
END //
DELIMITER ;

-- Ejemplo de uso: Precio máximo por tipo de libro
SELECT DISTINCT
    type                        AS tipo,
    fn_precioMaxTipo(type)      AS precio_maximo
FROM titles
WHERE type <> '' AND type IS NOT NULL
ORDER BY tipo;


--3
USE pubs;
DELIMITER //
CREATE Function fn_ingresoTitulo(p_title_id CHAR(6))
RETURNS DECIMAL (15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE ingreso DECIMAL(15,2);

    SELECT COALESCE(SUM(s.qty * t.price),0)  -- reemplaza los valores null con un valor, en este caso 0
    INTO ingreso
    FROM titles t
    LEFT JOIN sales s
    on t.title_id = s.title_id
    WHERE   t.title_id = p_title_id AND t.price is NOT NULL;
    RETURN ingreso;
END //
DELIMITER //

SELECT t.title_id,
        t.title,
        fn_ingresoTitulo(t.title_id) as ingreso_total
FROM    titles t 
WHERE   t.title <> ''
GROUP BY t.title_id, t.title
ORDER BY    ingreso_total desc;

--Ejercicio 4: Crear una función para obtener el nombre completo de un empleado a partir de su código.
SELECT * FROM employee;

DELIMITER //
CREATE Function fn_buscador (codigo CHAR(6))
RETURNS 
VARCHAR (100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE nombre_completo VARCHAR(100);

    SELECT CONCAT(fname,' ',lname)
    INTO nombre_completo
    FROM employee
    WHERE emp_id = codigo;

RETURN nombre_completo;
END //
DELIMITER//

select fn_buscador(1);

--Ejercicio 5: Crear ua función para calcular el precio promedio de libros publicados de cada editorial.

select * FROM titles;

use pubs;
DELIMITER //
CREATE  Function fn_promedio2 (id_editorial_promedio CHAR(6))
RETURNS DECIMAL (15,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE promedio DECIMAL (15,2);
        SELECT AVG(price)
        INTO promedio
        FROM    titles
        WHERE pub_id = id_editorial_promedio and price is NOT NULL;
        RETURN promedio;

END //

DELIMITER //


SELECT * FROM titles;

SELECT fn_promedio2(1389);
