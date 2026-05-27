--1 Crear la taula VideosProducte(producte_id, descripcio, video BLOB, format, durada_segons) amb les claus i restriccions adients.
CREATE TABLE VideosProducte (
    producte_id NUMBER PRIMARY KEY,
    descripcio VARCHAR2(255) NOT NULL,
    video BLOB NOT NULL,
    format VARCHAR2(10) NOT NULL,
    durada_segons NUMBER NOT NULL CHECK (durada_segons > 0)
);
--2 Crear la taula DocumentsContracte(client_id, contracte BLOB, tipus_document, mida_bytes) on s'hi guardaran contractes en format PDF.
CREATE TABLE DocumentsContracte (
    client_id NUMBER PRIMARY KEY,
    contracte BLOB NOT NULL,
    tipus_document VARCHAR2(50) NOT NULL,
    mida_bytes NUMBER NOT NULL CHECK (mida_bytes > 0)
);
--3 Crear una funció xml_client(client_id) que retorni un valor XMLType amb les dades del client (nom, email, etc.) i una llista de referències als seus documents contractuals (tipus, mida, identificador).
CREATE OR REPLACE FUNCTION xml_client(p_client_id NUMBER) RETURN XMLType IS
    v_xml XMLType;  
BEGIN
    SELECT XMLElement("Client", 
              XMLAttributes(c.client_id AS "ID", c.nom AS "Nom", c.email AS "Email"),
              (SELECT XMLAgg(XMLElement("Document", 
                                          XMLAttributes(d.tipus_document AS "Tipus", 
                                                     d.mida_bytes AS "Mida", 
                                                     d.client_id AS "ID"))) 
                FROM DocumentsContracte d 
                WHERE d.client_id = c.client_id)
     ) INTO v_xml
    FROM Clients c
    WHERE c.client_id = p_client_id;
    RETURN v_xml;
END;    
--4 Crear la taula RegistresXML(id, xml_data XMLType) per emmagatzemar documents XML generats.
CREATE TABLE RegistresXML (
    id NUMBER PRIMARY KEY,
    xml_data XMLType NOT NULL
);
--5 Implementar consultes amb XQuery sobre la taula RegistresXML per:
SELECT r.id, r.xml_data 
FROM RegistresXML r
WHERE r.xml_data.existsNode('/Client/Document[@Tipus="video" and @DuradaSegons > 60]') = 1;
--Llistar clients que tinguin més d'un document contractual associat.
SELECT r.id, r.xml_data 
FROM RegistresXML r
WHERE r.xml_data.existsNode('/Client[Document]') = 1
AND r.xml_data.count('/Client/Document') > 1;
--Comptar quants vídeos hi ha per cada format (mp4, avi, etc.).
SELECT r.id, r.xml_data     
FROM RegistresXML r
WHERE r.xml_data.existsNode('/Client/Document[@Tipus="video"]') = 1
GROUP BY r.id, r.xml_data
ORDER BY r.id;  
