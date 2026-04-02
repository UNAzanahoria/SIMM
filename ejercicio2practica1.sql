/*Ejercicio 2*/
-- Tipus Base
CREATE TYPE PERSONA AS OBJECT (
    codi NUMBER,
    dni VARCHAR2(10),
    nom VARCHAR2(50),
    adreca VARCHAR2(100),
    telefon VARCHAR2(15)
) NOT FINAL;

COMMIT;

-- Nivell 1: Empleat
CREATE TYPE EMPLEAT UNDER PERSONA (
    sou NUMBER,
    datacontracte DATE,
    correuCorp VARCHAR2(50),
    departament VARCHAR2(50),
    MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;

SELECT nom, EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM datacontracte) AS antiguitat 
FROM TABINVESTIGADOR;

-- Nivell 2: Investigador (sota Empleat)
CREATE TYPE INVESTIGADOR UNDER EMPLEAT (
    especialitat VARCHAR2(50),
    numpublicacions NUMBER
);

SELECT nom, 
       CASE 
         WHEN numpublicacions < 5 THEN 'Inicial'
         WHEN numpublicacions BETWEEN 5 AND 15 THEN 'Consolidat'
         ELSE 'Senior'
       END AS nivell 
FROM TABINVESTIGADOR;


COMMIT;

-- Nivell 2: Administratiu (sota Empleat)
CREATE TYPE ADMINISTRATIU UNDER EMPLEAT (
    carrec VARCHAR2(50),
    tipusjornada VARCHAR2(20)
);

SELECT nom, (sou * 14) AS sou_anual 
FROM TABADMINISTRATIU;

-- Nivell 1: Alumne
CREATE TYPE ALUMNE UNDER PERSONA (
    numexpedient NUMBER,
    correu VARCHAR2(50),
    datanaixement DATE
) NOT FINAL;

SELECT a.nom, a.edat() AS edat_actual FROM TALUMNE a;


-- Nivell 2: Alumne Grau (sota Alumne)
CREATE TYPE ALUMNEGRAU UNDER ALUMNE (
    titulacio VARCHAR2(50),
    durada NUMBER,
    anyprimera NUMBER
);


COMMIT;
-- Nivell 2: Alumne Master (sota Alumne)
CREATE TYPE ALUMNEMASTER UNDER ALUMNE (
    programa VARCHAR2(100),
    especialitat VARCHAR2(50),
    nummoduls NUMBER
);

SELECT nom, programa || ' - ' || especialitat || ' (' || nummoduls || ' moduls)' AS resum 
FROM TABALUMNEMASTER;
COMMIT;
-- 5. Taules per a cada classe
CREATE TABLE TABPERSONA OF PERSONA;
CREATE TABLE TABEMPLEAT OF EMPLEAT;
CREATE TABLE TABINVESTIGADOR OF INVESTIGADOR;
CREATE TABLE TABADMINISTRATIU OF ADMINISTRATIU;
CREATE TABLE TABALUMNE OF ALUMNE;
CREATE TABLE TABALUMNEGRAU OF ALUMNEGRAU;
CREATE TABLE TABALUMNEMASTER OF ALUMNEMASTER;
COMMIT;
-- 6. Inserció de dades
INSERT INTO TABINVESTIGADOR VALUES (INVESTIGADOR(1, '1A', 'Peu', 'C/1', '61', 2000, DATE '2020-01-01', 'p@m.com', 'Bio', 6));
INSERT INTO TABADMINISTRATIU VALUES (ADMINISTRATIU(2, '2B', 'Eva', 'C/2', '62', 1500, DATE '2022-01-01', 'e@m.com', 'Cap', 'Matí'));
INSERT INTO TABALUMNEGRAU VALUES (ALUMNEGRAU(3, '3C', 'Roc', 'C/3', '63', 100, 'r@u.com', DATE '2004-01-01', 'Informatica'));
INSERT INTO TABALUMNEMASTER VALUES (ALUMNEMASTER(4, '4D', 'Lia', 'C/4', '64', 200, 'l@u.com', DATE '2000-01-01'));

-- 7. Comprovar funcions
SELECT i.nom, i.nivellrecerca() FROM TABINVESTIGADOR i;
SELECT a.nom, a.souanual() FROM TABADMINISTRATIU a;
SELECT g.nom, g.anysrestants() FROM TABALUMNEGRAU g;
SELECT m.nom, m.resumestudis() FROM TABALUMNEMASTER m;
COMMIT;
-- 8. Taula PERSONA amb diferents subclasses
INSERT INTO TABPERSONA VALUES (PERSONA(10, '10X', 'Marc', 'C/10', '93'));
INSERT INTO TABPERSONA VALUES (INVESTIGADOR(11, '11Y', 'Julia', 'C/11', '94', 3000, DATE '2010-01-01', 'j@m.com', 'Fisica', 20));
INSERT INTO TABPERSONA VALUES (ALUMNEMASTER(12, '12Z', 'Pau', 'C/12', '95', 300, 'p@u.com', DATE '1995-01-01'));

-- Comprovar l'accés
SELECT p.nom, TREAT(VALUE(p) AS INVESTIGADOR).especialitat AS ESP FROM TABPERSONA p;
COMMIT;