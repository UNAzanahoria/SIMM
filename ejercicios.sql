CREATE TYPE Producto AS OBJECT (
    id_producto NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    precio NUMBER(6,2)
);
CREATE TABLE Productos OF Producto;
INSERT INTO Productos VALUES (1, 'Pelota',
'10');
INSERT INTO Productos VALUES (2, 'Coche',
'10');
INSERT INTO Productos VALUES (3, 'Tele',
'10');
CREATE TYPE ProductoElectronico UNDER Producto (
    garantia NUMBER
);
SELECT P.id_producto, P.nombre, P.precio, P.garantia FROM Productos P;
SELECT P.nombre, P.precio FROM Productos P WHERE P.precio > 50;
SELECT P.garantia, P.nombre FROM Productos WHERE garantia IS NOT NULL;

CREATE TYPE Cliente AS OBJECT (
    id_cliente NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    telefono VARCHAR2(15)
);
CREATE TABLE Clientes OF Cliente;
INSERT INTO Clientes VALUES (1, 'Alex',
'192837465');
INSERT INTO Clientes VALUES (2, 'Oliver',
'123456789');
INSERT INTO Clientes VALUES (3, 'Marc',
'987654321');
SELECT * FROM Clientes WHERE nombre LIKE 'H%';