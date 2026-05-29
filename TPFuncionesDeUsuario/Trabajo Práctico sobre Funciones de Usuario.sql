
-- Trabajo Práctico sobre Funciones de Usuario
USE pubs;

-- Ejercicio 1: Crear una función para calcular la regalía total de cada autor.

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

-- Ejemplo de uso: Regalía total por autor (solo autores con títulos)
SELECT
    a.au_id,
    CONCAT(a.au_fname, ' ', a.au_lname)   AS autor,
    fn_regaliaTotal(a.au_id)              AS regalia_total
FROM authors a
WHERE a.au_id IN (SELECT DISTINCT au_id FROM titleauthor)
ORDER BY regalia_total DESC;
    
-- Ejercicio 2: Crear una función para obtener el precio máximo de cada tipo de libro. 

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


--  Ejercicio 3: Crear una función para calcular el ingreso (cantidad vendida multiplicada por el precio) de cada título.
