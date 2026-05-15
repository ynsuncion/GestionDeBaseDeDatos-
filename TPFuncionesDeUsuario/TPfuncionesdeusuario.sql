RETURN total;
END//
DELIMITER;
-- Ejercicio 1: Regalía total por autor (Solo autores con titulos)
SELECT a.au_id,
		CONCAT(a.au_fname,'',a.au_lname) AS autor,
        fn_rgaliaTotal(a.au_id)			 AS regalia_total
FROM    authors a
WHERE a.au_id IN(SELECT DISTINCT au_id FROM titleauthor)
ORDER BY regalia_total DESC;
