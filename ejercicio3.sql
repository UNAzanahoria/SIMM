CREATE OR REPLACE TYPE Cliente AS OBJECT (
    nif      VARCHAR2(10),
    nombre   VARCHAR2(100),
    direccion VARCHAR2(200),
    telefono  VARCHAR2(20),
    MEMBER FUNCTION numCursos RETURN NUMBER
);

CREATE OR REPLACE TYPE Curso AS OBJECT (
    idCurso     NUMBER,
    nombre      VARCHAR2(100),
    horas       NUMBER,
    precio      NUMBER(8,2),
    refCliente  REF Cliente,
    MEMBER FUNCTION coordinador RETURN VARCHAR2,
    MEMBER FUNCTION activo RETURN CHAR
) NOT FINAL;

CREATE OR REPLACE TYPE Empleado AS OBJECT (
    dni           VARCHAR2(10),
    nombre        VARCHAR2(50),
    apellidos     VARCHAR2(100),
    fechaContrato DATE,
    telefono      VARCHAR2(20),
    MEMBER FUNCTION antiguedad RETURN NUMBER,
    MEMBER FUNCTION numParticipaciones RETURN NUMBER
) NOT FINAL;

CREATE OR REPLACE TYPE CursoActivo UNDER Curso (
    fechaInicio      DATE,
    fechaFinPrevista DATE,
    modalidad        VARCHAR2(20),
    MEMBER FUNCTION moduloActual RETURN VARCHAR2
);

CREATE OR REPLACE TYPE CursoHistorico UNDER Curso (
    fechaFinal  DATE,
    valoracion  NUMBER(2,1)
);

CREATE OR REPLACE TYPE Formador UNDER Empleado (
    especialidad VARCHAR2(50),
    nivel        VARCHAR2(20)
);

CREATE OR REPLACE TYPE Coordinador UNDER Empleado (
    area      VARCHAR2(50),
    despacho  VARCHAR2(20)
);

CREATE OR REPLACE TYPE Tecnico UNDER Empleado (
    certificacion VARCHAR2(50),
    sistema       VARCHAR2(50)
);

CREATE OR REPLACE TYPE Modulo AS OBJECT (
    idModulo   NUMBER,
    nombre     VARCHAR2(100),
    fechaInicio DATE,
    fechaFin    DATE,
    MEMBER FUNCTION numCursos RETURN NUMBER
);

CREATE OR REPLACE TYPE Coordina AS OBJECT (
    refCurso    REF Curso,
    refEmpleado REF Empleado
);

CREATE OR REPLACE TYPE Participa AS OBJECT (
    refCurso    REF Curso,
    refEmpleado REF Empleado
);

CREATE OR REPLACE TYPE ModulosCurso AS OBJECT (
    refCursoActivo REF CursoActivo,
    refModulo      REF Modulo
);

CREATE TABLE Clientes OF Cliente (
    nif PRIMARY KEY
);

CREATE TABLE Empleados OF Empleado (
    dni PRIMARY KEY
);

CREATE TABLE Cursos OF Curso (
    idCurso PRIMARY KEY
);

CREATE TABLE Modulos OF Modulo (
    idModulo PRIMARY KEY
);

CREATE TABLE Coordinaciones OF Coordina;
CREATE TABLE Participaciones OF Participa;
CREATE TABLE ModulosCursos OF ModulosCurso;

/*Oliver las inserciones se las he pedido al DeepSeek porque las que tenia hechas en otro fichero y las he perdido la verdad*/

INSERT INTO Clientes VALUES (Cliente('12345678A', 'Joan Garcia', 'Carrer Major 1', '666111222'));
INSERT INTO Clientes VALUES (Cliente('87654321B', 'Marta Puig', 'Avinguda Llibertat 5', '666333444'));

INSERT INTO Empleados VALUES (Coordinador('11111111A', 'Pere', 'Soler', DATE '2015-01-10', '666555666', 'Informatica', 'D-101'));
INSERT INTO Empleados VALUES (Formador('22222222B', 'Anna', 'Vila', DATE '2018-06-15', '666777888', 'Bases de datos', 'Avanzado'));
INSERT INTO Empleados VALUES (Tecnico('33333333C', 'Carles', 'Roig', DATE '2020-03-01', '666999000', 'Oracle DBA', 'Linux'));

INSERT INTO Cursos
SELECT CursoActivo(
    101, 'SQL Avanzado', 30, 450.00,
    (SELECT REF(c) FROM Clientes c WHERE c.nif = '12345678A'),
    DATE '2026-04-01', DATE '2026-05-15', 'Presencial'
) FROM DUAL;

INSERT INTO Cursos
SELECT CursoHistorico(
    102, 'Introduccion PL/SQL', 20, 300.00,
    (SELECT REF(c) FROM Clientes c WHERE c.nif = '87654321B'),
    DATE '2025-12-20', 4.5
) FROM DUAL;

INSERT INTO Cursos
SELECT CursoActivo(
    103, 'Administracion Oracle', 40, 600.00,
    (SELECT REF(c) FROM Clientes c WHERE c.nif = '12345678A'),
    DATE '2026-03-01', DATE '2026-06-01', 'En linea'
) FROM DUAL;

INSERT INTO Modulos VALUES (Modulo(1, 'Modulo 1: Fundamentos', DATE '2026-04-01', DATE '2026-04-15'));
INSERT INTO Modulos VALUES (Modulo(2, 'Modulo 2: Optimizacion', DATE '2026-04-16', NULL));
INSERT INTO Modulos VALUES (Modulo(3, 'Modulo 3: Seguridad', DATE '2026-05-01', DATE '2026-05-15'));

INSERT INTO Coordinaciones
SELECT Coordina(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 101),
    (SELECT REF(e) FROM Empleados e WHERE e.dni = '11111111A')
) FROM DUAL;

INSERT INTO Participaciones
SELECT Participa(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 101),
    (SELECT REF(e) FROM Empleados e WHERE e.dni = '22222222B')
) FROM DUAL;

INSERT INTO Participaciones
SELECT Participa(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 101),
    (SELECT REF(e) FROM Empleados e WHERE e.dni = '33333333C')
) FROM DUAL;

INSERT INTO Participaciones
SELECT Participa(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 102),
    (SELECT REF(e) FROM Empleados e WHERE e.dni = '33333333C')
) FROM DUAL;

INSERT INTO ModulosCursos
SELECT ModulosCurso(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 101),
    (SELECT REF(m) FROM Modulos m WHERE m.idModulo = 1)
) FROM DUAL;

INSERT INTO ModulosCursos
SELECT ModulosCurso(
    (SELECT REF(c) FROM Cursos c WHERE c.idCurso = 101),
    (SELECT REF(m) FROM Modulos m WHERE m.idModulo = 2)
) FROM DUAL;

CREATE OR REPLACE TYPE BODY Cliente AS
    MEMBER FUNCTION numCursos RETURN NUMBER IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt
        FROM Cursos c
        WHERE c.refCliente.nif = SELF.nif;
        RETURN cnt;
    END;
END;

CREATE OR REPLACE TYPE BODY Empleado AS
    MEMBER FUNCTION antiguedad RETURN NUMBER IS
    BEGIN
        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, SELF.fechaContrato) / 12);
    END;

    MEMBER FUNCTION numParticipaciones RETURN NUMBER IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt
        FROM Participaciones p
        WHERE p.refEmpleado.dni = SELF.dni;
        RETURN cnt;
    END;
END;

CREATE OR REPLACE TYPE BODY Curso AS
    MEMBER FUNCTION coordinador RETURN VARCHAR2 IS
        coordNombre VARCHAR2(200);
    BEGIN
        SELECT e.nombre || ' ' || e.apellidos INTO coordNombre
        FROM Coordinaciones co, Empleados e
        WHERE co.refCurso.idCurso = SELF.idCurso
          AND co.refEmpleado.dni = e.dni;
        RETURN coordNombre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Sin coordinador asignado';
        WHEN TOO_MANY_ROWS THEN
            RETURN 'Mas de un coordinador (error)';
    END;

    MEMBER FUNCTION activo RETURN CHAR IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt
        FROM Cursos c
        WHERE c.idCurso = SELF.idCurso
          AND VALUE(c) IS OF (CursoActivo);
        IF cnt > 0 THEN
            RETURN 'T';
        ELSE
            RETURN 'F';
        END IF;
    END;
END;

CREATE OR REPLACE TYPE BODY CursoActivo AS
    MEMBER FUNCTION moduloActual RETURN VARCHAR2 IS
        modNombre VARCHAR2(100);
    BEGIN
        SELECT m.nombre INTO modNombre
        FROM ModulosCursos mc, Modulos m
        WHERE mc.refCursoActivo.idCurso = SELF.idCurso
          AND mc.refModulo.idModulo = m.idModulo
          AND m.fechaFin IS NULL
          AND ROWNUM = 1;
        RETURN modNombre;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Ningun modulo activo en este momento';
    END;
END;

CREATE OR REPLACE TYPE BODY Modulo AS
    MEMBER FUNCTION numCursos RETURN NUMBER IS
        cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO cnt
        FROM ModulosCursos mc
        WHERE mc.refModulo.idModulo = SELF.idModulo;
        RETURN cnt;
    END;
END;

SELECT c.nif, c.nombre, c.numCursos() AS "Cursos contratados"
FROM Clientes c;

SELECT e.dni, e.nombre, e.apellidos,
       e.antiguedad() AS "Anios antiguedad",
       e.numParticipaciones() AS "Cursos participa"
FROM Empleados e;

SELECT c.idCurso, c.nombre,
       c.coordinador() AS "Coordinador",
       c.activo() AS "Es activo?"
FROM Cursos c;

SELECT c.idCurso, c.nombre,
       TREAT(VALUE(c) AS CursoActivo).moduloActual() AS "Modulo actual"
FROM Cursos c
WHERE VALUE(c) IS OF (CursoActivo);

SELECT m.idModulo, m.nombre, m.numCursos() AS "Aparece en cursos"
FROM Modulos m;
