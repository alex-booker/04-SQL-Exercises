-- Create Tables

CREATE TABLE clientes (
cliente_id INT PRIMARY KEY,
nombre VARCHAR(100),
ciudad VARCHAR(100),
fecha_registro DATE
);

CREATE TABLE categorias (
categoria_id INT PRIMARY KEY,
nombre_categoria VARCHAR(100)
);

CREATE TABLE productos (
producto_id INT PRIMARY KEY,
nombre_producto VARCHAR(100),
categoria_id INT,
precio DECIMAL(10,2),
FOREIGN KEY (categoria_id)
REFERENCES categorias(categoria_id)
);

CREATE TABLE pedidos (
pedido_id INT PRIMARY KEY,
cliente_id INT,
fecha_pedido DATE,
FOREIGN KEY (cliente_id)
REFERENCES clientes(cliente_id)
);

CREATE TABLE detalle_pedidos (
detalle_id INT PRIMARY KEY,
pedido_id INT,
producto_id INT,
cantidad INT,
FOREIGN KEY (pedido_id)
REFERENCES pedidos(pedido_id),
FOREIGN KEY (producto_id)
REFERENCES productos(producto_id)
);

-- Insertar Datos
INSERT INTO clientes VALUES
(1,'Ana','Madrid','2023-01-10'),
(2,'Luis','Barcelona','2023-02-15'),
(3,'Marta','Valencia','2023-03-20'),
(4,'Pedro','Madrid','2023-04-05'),
(5,'Sofia','Sevilla','2023-05-12'), 
(6,'Mariana','Mexico','2023-07-17');

INSERT INTO categorias VALUES
(1,'Electrónica'),
(2,'Hogar'),
(3,'Deportes');

INSERT INTO productos VALUES
(1,'Laptop',1,1200),
(2,'Monitor',1,300),
(3,'Teclado',1,50),
(4,'Silla Oficina',2,200),
(5,'Lámpara',2,40),
(6,'Bicicleta',3,800),
(7,'Mancuernas',3,100);

INSERT INTO pedidos VALUES
(1,1,'2024-01-10'),
(2,2,'2024-01-11'),
(3,1,'2024-01-15'),
(4,3,'2024-02-01'),
(5,4,'2024-02-10'),
(6,5,'2024-02-15');

INSERT INTO detalle_pedidos VALUES
(1,1,1,1),
(2,1,3,2),
(3,2,2,1),
(4,2,5,3),
(5,3,6,1),
(6,4,7,4),
(7,4,3,2),
(8,5,4,1),
(9,6,1,1),
(10,6,2,2);


-- Tablas creadas
-- clientes, categorias, productos, pedidos, detalle_pedidos

-- 1. Inner join
Select 
C.categoria_id, C.nombre_categoria, P.nombre_producto, P.precio 
FROM categorias C 
INNER JOIN productos P
ON C.categoria_id = P.categoria_id;

-- 2. Left Join
Select U.cliente_id, U.nombre, U.ciudad, U.fecha_registro, E.fecha_pedido 
From clientes U 
LEFT JOIN pedidos E 
ON U.cliente_id = E.cliente_id 

-- 3. Right join
SELECT * 
FROM clientes U 
RIGHT JOIN pedidos E 
ON U.cliente_id = E.cliente_id 

-- 4. Left Join NULL
Select *  
From clientes U 
LEFT JOIN pedidos E 
ON U.cliente_id = E.cliente_id 
Where E.fecha_pedido is NULL

-- 5. WHERE, IN 
Select *  
From clientes U 
LEFT JOIN pedidos E 
ON U.cliente_id = E.cliente_id 
WHERE U.ciudad IN ('Madrid', 'Mexico') 

-- 6.WHERE, 2 AND 
Select *  
From clientes U 
LEFT JOIN pedidos E 
ON U.cliente_id = E.cliente_id 
WHERE U.ciudad IN ('Madrid', 'Mexico') 
AND U.nombre = 'Ana' AND E.pedido_id = 3 

-- 7.HAVING - Muestra categorias con mas de 2 productos, junto al conteo de productos por categoria.
SELECT P.categoria_id, C.nombre_categoria, COUNT(*) AS num_productos
FROM productos P 
INNER JOIN categorias C 
ON P.categoria_id = C.categoria_id
GROUP BY P.categoria_id, C.nombre_categoria
HAVING COUNT(*) > 2;

-- 8. SubQuery
SELECT * 
FROM clientes U 
INNER JOIN pedidos E ON U.cliente_id = E.cliente_id 
WHERE U.ciudad IN ('Madrid', 'Barcelona', 'Sevilla', 'Mexico') 
AND E.pedido_id IN ( 
    SELECT pedido_id FROM detalle_pedidos  
); 

-- 9. Subquery with Where
SELECT * 
FROM clientes U 
INNER JOIN pedidos E  
ON U.cliente_id = E.cliente_id 
WHERE U.ciudad IN ('Madrid', 'Barcelona', 'Sevilla', 'Mexico') 
AND E.pedido_id IN ( 
    SELECT pedido_id  
    FROM detalle_pedidos  
    WHERE cantidad >2 
); 

-- 10. function & Group By 
SELECT 
    C.categoria_id, 
    C.nombre_categoria, 
    SUM(P.precio) AS total 
FROM categorias C 
INNER JOIN productos P 
    ON C.categoria_id = P.categoria_id 
WHERE C.nombre_categoria IN ('Electrónica', 'Deportes') 
GROUP BY C.categoria_id, C.nombre_categoria 
ORDER BY total DESC; 

-- 11.SubQuery with Group By 
SELECT 
    C.categoria_id, 
    C.nombre_categoria, 
    P.nombre_producto, 
    P.precio AS precio_alto 
FROM categorias C 
INNER JOIN productos P 
    ON C.categoria_id = P.categoria_id 
INNER JOIN ( 
    SELECT categoria_id, MAX(precio) AS precio_max 
    FROM productos 
    GROUP BY categoria_id 
) M 
    ON P.categoria_id = M.categoria_id 
    AND P.precio = M.precio_max 
WHERE M.precio_max >= 200; 

-- 12.Windows Function 
SELECT  
    C.categoria_id,  
    C.nombre_categoria,  
    P.nombre_producto,  
    P.precio, 
    SUM(P.precio) OVER (PARTITION BY C.categoria_id) AS total_categoria 
FROM categorias C  
INNER JOIN productos P  
    ON C.categoria_id = P.categoria_id  
ORDER BY C.nombre_categoria, P.precio DESC 
; 

-- 13. CTE -  categorias - por encima del promedio general
WITH promedio_por_categoria AS ( 
    SELECT categoria_id, 
    	AVG(precio) AS promedio_categoria 
    FROM productos  
    GROUP BY categoria_id 
  ) 
SELECT C.nombre_categoria, P.promedio_categoria 
FROM promedio_por_categoria P 
INNER JOIN Categorias C 
ON P.categoria_id = C.categoria_id 
WHERE 
	P.promedio_categoria > ( 
  SELECT AVG(precio) 
  From productos 
); 
