-- Trabajo Practico sobre triggers
create database testDisparador;

USE testDisparador;

CREATE TABLE alumnos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    nota DECIMAL(4,2) NOT NULL,
    PRIMARY KEY (id)
);

/*Trigger 1: trigger_check_nota_before_insert
Se ejecuta sobre la tabla alumnos.
Se ejecuta antes de una operación de inserción.
Si el nuevo valor de la nota que se quiere insertar es negativo, se guarda como 0.
Si el nuevo valor de la nota que se quiere insertar es mayor que 10, se guarda como 10.
*/

DELIMITER //
CREATE TRIGGER trigger_check_nota_before_insert
BEFORE INSERT -- antes de ejecutar este codigo insertar en la tabla alumnos 
ON alumnos 
FOR EACH ROW -- para que el trigger entre en cada fila de la tabla, en cda fila que se inserte 
BEGIN
IF NEW.nota < 0 THEN
        SET NEW.nota = 0;
    END IF;

    IF NEW.nota > 10 THEN
        SET NEW.nota = 10;
    END IF;
END//

DELIMITER ;

INSERT INTO alumnos(nombre, apellido, nota)
VALUES ('Lucas', 'Martínez', -4);

select * from alumnos;


/*Trigger2 : trigger_check_nota_before_update
Se ejecuta sobre la tabla alumnos.
Se ejecuta antes de una operación de actualización.
Si el nuevo valor de la nota que se quiere actualizar es negativo, se guarda como 0.
Si el nuevo valor de la nota que se quiere actualizar es mayor que 10, se guarda como 10.
Una vez creados los triggers escriba 3 sentencias de inserción y actualización sobre la tabla alumnos y verifica que los triggers se están ejecutando correctamente.
*/

DELIMITER //

CREATE TRIGGER trigger_check_nota_before_update
BEFORE UPDATE
ON alumnos
FOR EACH ROW
BEGIN
    IF NEW.nota < 0 THEN
        SET NEW.nota = 0;
    END IF;

    IF NEW.nota > 10 THEN
        SET NEW.nota = 10;
    END IF;
END//

DELIMITER ;

INSERT INTO alumnos(nombre, apellido, nota)
VALUES ('Juan', 'Pérez', -5);

INSERT INTO alumnos(nombre, apellido, nota)
VALUES ('Ana', 'Gómez', 15);

INSERT INTO alumnos(nombre, apellido, nota)
VALUES ('Luis', 'Martínez', 8);

SELECT * FROM alumnos;

UPDATE alumnos
SET nota = -3
WHERE id = 3;