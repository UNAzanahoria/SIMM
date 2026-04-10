CREATE TYPE Adreca AS OBJECT (
    carrer VARCHAR2(50),
    ciutat VARCHAR2(50),
    codi_postal VARCHAR2(10)
);


CREATE TYPE Telefon AS OBJECT (
    tipus VARCHAR2(15),
    numero VARCHAR2(15)
);


CREATE TYPE Telefons AS VARRAY(2) OF Telefon;

CREATE TYPE Proveidor AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    adreca Adreca,
    vec_telefons Telefons,
    correu_electronic VARCHAR2(50)
);

CREATE TYPE Material AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(100),
    descripcio VARCHAR2(200),
    cost_unitari NUMBER(10,2)
);

CREATE TYPE Linia_compra AS OBJECT(
    codi NUMBER,
    ref_material REF Material,
    quantitat NUMBER,
    descompte NUMBER,
    MEMBER FUNCTION subtotal RETURN NUMBER
);

CREATE TYPE BODY Linia_compra AS
    MEMBER FUNCTION subtotal RETURN NUMBER IS
        preu NUMBER;
    BEGIN
        SELECT m.cost_unitari INTO preu
        FROM Materials m
        WHERE REF(m) = SELF.ref_material;

        RETURN (preu * quantitat) * (1 - descompte/100);
    END;
END;

CREATE TYPE Taula_linies AS TABLE OF Linia_compra;

CREATE TYPE Compra AS OBJECT (
    codi NUMBER,
    data_compra VARCHAR2(20),
    ref_proveidor REF Proveidor,
    taula_linies Taula_linies,
    MEMBER FUNCTION total RETURN NUMBER
);

CREATE TYPE BODY Compra AS
    MEMBER FUNCTION total RETURN NUMBER IS
        suma NUMBER := 0;
    BEGIN
        FOR i IN 1..taula_linies.COUNT LOOP
            suma := suma + taula_linies(i).subtotal();
        END LOOP;
        RETURN suma;
    END;
END;

CREATE TABLE Materials OF Material (
    codi PRIMARY KEY
);

CREATE TABLE Proveidors OF Proveidor (
    codi PRIMARY KEY
);

CREATE TABLE Compres OF Compra (
    codi PRIMARY KEY

NESTED TABLE taula_linies STORE AS linies_nested;


INSERT INTO Materials VALUES (1, 'Teclado', 'Teclado mecanico', 50);
INSERT INTO Materials VALUES (2, 'Raton', 'Raton gaming', 30);

INSERT INTO Proveidors VALUES (
    1,
    'Proveedor1',
    Adreca('Calle 1', 'Barcelona', '08001'),
    Telefons(
        Telefon('movil','123456789'),
        Telefon('fijo','987654321')
    ),
    'prov1@email.com'
);

INSERT INTO Compres VALUES (
    1,
    '10-04-2026',
    (SELECT REF(p) FROM Proveidors p WHERE p.codi = 1),
    Taula_linies(
        Linia_compra(
            1,
            (SELECT REF(m) FROM Materials m WHERE m.codi = 1),
            2,
            10
        ),
        Linia_compra(
            2,
            (SELECT REF(m) FROM Materials m WHERE m.codi = 2),
            1,
            0
        )
    )
);

SELECT l.codi, l.subtotal()
FROM Compres c, TABLE(c.taula_linies) l;

SELECT c.codi, c.total()
FROM Compres c;
