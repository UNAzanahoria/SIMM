/*Ejercicios 1*/
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

/*Ejercicios 2*/
CREATE TYPE Vehiculo AS OBJECT (
    id_vehiculo NUMBER PRIMARY KEY,
    marca VARCHAR2(50),
    modelo VARCHAR2(50),
    precio NUMBER(10,2)
);
CREATE TABLE Vehiculos OF Vehiculo;
INSERT INTO Vehiculos VALUES (1, 'NISSAN',
'Almera', 999999);
INSERT INTO Vehiculos VALUES (2, 'SKODA',
'Fabia', 9);
INSERT INTO Vehiculos VALUES (3, 'Ferrari',
'Superb', 99999);
CREATE TYPE VehiculoElectrico UNDER Vehiculo (
    autonomia NUMBER
);
INSERT INTO Vehiculos VALUES (4, 'FIAT',
'500', 99999, 350);
SELECT * FROM Vehiculos;
SELECT V.id_vehiculo, V.marca, V.modelo FROM Vehiculos V;
SELECT * FROM Vehiculos V WHERE V.precio > 20000;
SELECT V.autonomia, V.marca FROM Vehiculos;
CREATE TYPE Propietario AS OBJECT (
    id_propietario NUMBER,
    nombre VARCHAR2(50),
    telefono VARCHAR2(15),
    coche REF Vehiculo
);
CREATE TABLE Propietarios OF Propietario(
    responsable SCOPE IS Vehiculos
);
INSERT INTO Propietarios VALUES (1, 'Iker',
'12356789', 'Nissan');
INSERT INTO Propietarios VALUES (2, 'Oliver',
'987654321', 'Skoda');
SELECT TREAT(VALUE(P) AS Propietario).responsable FROM Propietario P;

/*Ejercicio T2 BDOR*/
CREATE TYPE Adreca AS OBJECT (
    carrer VARCHAR PRIMARY KEY,
    ciutat VARCHAR(20),
    codipostal VARCHAR(10) 
);
CREATE TYPE Telefon AS OBJECT (
    tipus VARCHAR(15),
    numero VARCHAR PRIMARY KEY
);
CREATE TYPE Telefonos AS VARRAY(2) OF Telefon;
CREATE TYPE Provedor AS OBJECT (
    codi NUMBER PRIMARY KEY,
    nom VARCHAR(10),
    adreça adreca,
    vec_telefons Telefons,
    correu_electronico VARCHAR(20)
);
CREATE TYPE Material AS OBJECT (
    codi NUMBER PRIMARY KEY,
    nom VARCHAR(116),
    descripcio VARCHAR(200),
    cost_unitari NUMBER(100,2)
);
CREATE TYPE Linia_compra AS OBJECT(
    codi NUMBER PRIMARY KEY,
    ref_material NUMBER FOREIGN KEY REFERENCES Material(codi),
    quantitat NUMBER(999),
    descompte NUMBER(10)
);
CREATE TABLE linies OF Linia_compra;
CREATE TYPE compra AS OBJECT (
    codi NUMBER PRIMARY KEY,
    data_compra VARCHAR(11),
    ref_proveidor VARCHAR FOREIGN KEY REFERENCES Provedor(codi),
    taula_linies linies
);
SELECT codi, SUM((cost_unitari * quantitat) * (1 - (descompte / 100))) AS total_compra
FROM Linia_compra GROUP BY codi;
SELECT codi, SUM(total_compra) AS cost_total_compra
FROM linia_compra
WHERE codi = 123 GROUP BY codi;