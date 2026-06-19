create database tp_procedimientos;

use tp_procedimientos;

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE productos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) DEFAULT '',
  precio DECIMAL(10,2) NOT NULL,
  stock INT DEFAULT 0
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);


--  Insercion de registros
INSERT INTO clientes (nombre, direccion, telefono) VALUES
('Juan Pérez', 'Calle Falsa 123', '555-1234'),
('María García', 'Avenida Siempreviva 742', '555-5678'),
('Pedro González', 'Calle 13 No. 6-11', '555-9101'),
('Ana Hernández', 'Carrera 7 No. 32-60', '555-1212'),
('Luisa Rodríguez', 'Avenida Boyacá No. 64C-31', '555-1415'),
('Carlos Vargas', 'Carrera 15 No. 93-75', '555-1617'),
('Cristina Gómez', 'Carrera 45 No. 34-87', '555-1819'),
('Javier Torres', 'Calle 45 No. 23-09', '555-2022'),
('Laura Sánchez', 'Avenida 68 No. 56-18', '555-2225'),
('Andrés Díaz', 'Carrera 7 No. 11-07', '555-2428');


INSERT INTO productos (nombre, descripcion, precio, stock)
VALUES ('Laptop', 'Laptop HP 15", 8GB RAM, 1TB HDD', 1500.00, 10),
('Smartphone', 'Smartphone Samsung Galaxy S21', 1000.00, 15),
('Tablet', 'Tablet Apple iPad Pro 12.9"', 1200.00, 5),
('Monitor', 'Monitor LG 27", 1440p', 500.00, 20),
('Teclado', 'Teclado mecánico Logitech G513', 100.00, 30),
('Mouse', 'Mouse inalámbrico Logitech M720', 50.00, 25),
('Auriculares', 'Auriculares Sony WH-1000XM4', 300.00, 10),
('Altavoces', 'Altavoces Bose SoundLink Revolve+', 250.00, 8),
('Cámara', 'Cámara Canon EOS R5', 4000.00, 2),
('Impresora', 'Impresora multifunción HP LaserJet Pro M428fdw', 600.00, 5);


INSERT INTO ventas (cliente_id, producto_id, cantidad, fecha) VALUES
(1, 1, 5, '2022-01-01'),
(1, 2, 3, '2022-01-02'),
(2, 3, 2, '2022-01-03'),
(2, 1, 1, '2022-01-04'),
(3, 2, 4, '2022-01-05'),
(3, 3, 1, '2022-01-06'),
(4, 1, 3, '2022-01-07'),
(4, 2, 2, '2022-01-08'),
(5, 3, 6, '2022-01-09'),
(5, 1, 2, '2022-01-10');

select * from clientes;
select * from productos;
select * from ventas;



-- 1. Procedimiento que muestra el total de ventas por producto
CREATE PROCEDURE total_ventas_por_producto()
BEGIN
    SELECT p.nombre AS producto, SUM(v.cantidad) AS total_ventas
    FROM productos p
    LEFT JOIN ventas v ON p.id = v.producto_id
    GROUP BY p.id;
END;

call total_ventas_por_producto();

-- 2. Procedimiento que actualiza el stock de un producto y devuelve su nuevo valor
CREATE PROCEDURE actualizar_stock(IN p_producto_id INT, IN p_cantidad INT, OUT p_nuevo_stock INT)
BEGIN
    UPDATE productos
    SET stock = stock + p_cantidad
    WHERE id = p_producto_id;

    SELECT stock INTO p_nuevo_stock
    FROM productos
    WHERE id = p_producto_id;
END;

call actualizar_stock(1, -2, @nuevo_stock);
SELECT @nuevo_stock AS nuevo_stock;

-- 3. Procedimiento que muestra la lista de productos con un stock menor a cierto valor
CREATE PROCEDURE productos_bajo_stock(IN p_limite INT)
BEGIN
    SELECT nombre, stock
    FROM productos
    WHERE stock < p_limite;
END;

call productos_bajo_stock(10);

-- 4. Procedimiento que muestra el nombre y la cantidad de compras de un cliente en un rango de fechas
CREATE PROCEDURE compras_cliente_rango_fechas(IN p_cliente_id INT, IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT p.nombre AS producto, SUM(v.cantidad) AS total_compras
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE v.cliente_id = p_cliente_id AND v.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY p.id;
END; 
call compras_cliente_rango_fechas(1, '2022-01-01', '2022-01-10');
-- 5. Procedimiento que muestra el promedio de precio de los productos comprados por un cliente
CREATE PROCEDURE promedio_precio_compras_cliente(IN p_cliente_id INT)
BEGIN 
    SELECT AVG(p.precio) AS promedio_precio
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE v.cliente_id = p_cliente_id;
END;
call promedio_precio_compras_cliente(1);

-- 6. Procedimiento que muestra la lista de clientes que han comprado un producto en particular

CREATE PROCEDURE clientes_por_producto(IN p_producto_id INT)
BEGIN
    SELECT c.nombre AS cliente, SUM(v.cantidad) AS total_compras
    FROM ventas v
    JOIN clientes c ON v.cliente_id = c.id
    WHERE v.producto_id = p_producto_id
    GROUP BY c.id;
END; 
call clientes_por_producto(1);
-- 7. Procedimiento que actualiza el precio de un producto y devuelve su nuevo valor

CREATE PROCEDURE actualizar_precio(IN p_producto_id INT, IN p_nuevo_precio DECIMAL(10,2), OUT p_precio_actualizado DECIMAL(10,2))
BEGIN
    UPDATE productos
    SET precio = p_nuevo_precio
    WHERE id = p_producto_id;

    SELECT precio INTO p_precio_actualizado
    FROM productos
    WHERE id = p_producto_id;
END;  
call actualizar_precio(1, 1600.00, @precio_actualizado);
SELECT @precio_actualizado AS precio_actualizado;

-- 8. Procedimiento que muestra el nombre y el stock de los productos que se han vendido en un rango de fechas

CREATE PROCEDURE productos_vendidos_rango_fechas(IN p_fecha_inicio DATE, IN p_fecha_fin DATE)
BEGIN
    SELECT p.nombre AS producto, SUM(v.cantidad) AS total_vendido, p.stock
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    WHERE v.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY p.id;
END; 
call productos_vendidos_rango_fechas('2022-01-01', '2022-01-10');

-- 9. Procedimiento que muestra el total de ventas por cliente
CREATE PROCEDURE total_ventas_por_cliente()
BEGIN
    SELECT c.nombre AS cliente, SUM(v.cantidad) AS total_ventas
    FROM clientes c
    LEFT JOIN ventas v ON c.id = v.cliente_id
    GROUP BY c.id;
END;
call total_ventas_por_cliente();

-- 10. Procedimiento que muestra la lista de productos ordenada por precio de mayor a menor
CREATE PROCEDURE productos_ordenados_por_precio()
BEGIN
    SELECT nombre, precio
    FROM productos
    ORDER BY precio DESC;
END; 
call productos_ordenados_por_precio();

