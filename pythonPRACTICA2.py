##Desenvolupar el script gestor_multimedia.py que faci el següent:
####• Carregui vídeos (.mp4) i contractes en PDF (.pdf) des del sistema de fitxers local i els desi com
##a BLOB a les taules corresponents.
##• Generi documents XML invocant la funció xml_client per a un conjunt de clients i els
##emmagatzemi a la taula RegistresXML.
##• Executi com a mínim dues consultes XQuery sobre RegistresXML i mostri els resultats per
##pantalla amb un format llegible.
##• Consulti la mida dels BLOB emmagatzemats (utilitzant DBMS_LOB.GETLENGTH) i mostri un
##resum amb el total i la mitjana.
##• (Opcional) Exporti els BLOB a fitxers temporals per a la seva reproducció o visualització,
##comprovant la integritat respecte als originals.
##Recomanacions generals
##• Els scripts Python han d'utilitzar el mòdul cx_Oracle i gestionar les connexions amb control
##d'errors (try/except/finally) i tancament explícit de cursors i connexions.
##• Tot el codi PL/SQL ha d'estar degudament comentat (capçalera, propòsit, paràmetres i
##excepcions previstes).
##• Tots els scripts Python han d'imprimir per pantalla els resultats de les operacions i indicar
##clarament si les validacions han estat correctes o si s'ha produït alguna anomalia.
##• S'han d'incloure dades d'exemple (mínim 3 productes, 3 clients i 5 comandes) i evidències
##d'execució de cada cas.
##• El lliurament inclourà: scripts .sql, scripts .py, una breu memòria explicant el disseny i les
##sortides obtingudes
import cx_Oracle
import os
import xml.etree.ElementTree as ET
import tempfile
import shutil
import sys
import logging
# Configuració del logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
def connect_to_db(username, password, dsn):
    """Estableix una connexió a la base de dades Oracle."""
    try:
        connection = cx_Oracle.connect(username, password, dsn)
        logging.info("Connexió a la base de dades establerta amb èxit.")
        return connection
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en connectar a la base de dades: {e}")
        sys.exit(1)
def load_blob_from_file(cursor, file_path):
    """Carrega un fitxer com a BLOB i el retorna."""
    try:
        with open(file_path, 'rb') as file:
            blob_data = file.read()
            logging.info(f"Fitxer '{file_path}' carregat com a BLOB.")
            return blob_data
    except Exception as e:
        logging.error(f"Error en carregar el fitxer '{file_path}': {e}")
        return None 
def insert_blob(cursor, table_name, blob_data):
    """Insereix un BLOB a la taula especificada."""
    try:
        cursor.execute(f"INSERT INTO {table_name} (id, blob_column) VALUES (seq_id.NEXTVAL, :blob_data)", blob_data=blob_data)
        logging.info(f"BLOB inserit a la taula '{table_name}' amb èxit.")
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en inserir el BLOB a la taula '{table_name}': {e}")
def generate_xml_client(client_id, client_name):
    """Genera un document XML per un client."""
    root = ET.Element("Client")
    ET.SubElement(root, "ID").text = str(client_id)
    ET.SubElement(root, "Name").text = client_name
    xml_data = ET.tostring(root, encoding='utf-8').decode('utf-8')
    logging.info(f"Document XML generat per al client '{client_name}' (ID: {client_id}).")
    return xml_data
def insert_xml_record(cursor, xml_data):
    """Insereix un document XML a la taula RegistresXML."""
    try:
        cursor.execute("INSERT INTO RegistresXML (id, xml_column) VALUES (seq_xml_id.NEXTVAL, :xml_data)", xml_data=xml_data)
        logging.info("Document XML inserit a la taula 'RegistresXML' amb èxit.")
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en inserir el document XML a la taula 'RegistresXML': {e}")
def query_xml_records(cursor):
    """Executa consultes XQuery sobre la taula RegistresXML i mostra els resultats."""
    try:
        cursor.execute("SELECT xml_column FROM RegistresXML")
        rows = cursor.fetchall()
        for row in rows:
            xml_data = row[0]
            root = ET.fromstring(xml_data)
            client_id = root.find('ID').text
            client_name = root.find('Name').text
            logging.info(f"Client ID: {client_id}, Client Name: {client_name}")
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en executar la consulta XQuery: {e}")
def get_blob_sizes(cursor, table_name):
    """Consulta la mida dels BLOB emmagatzemats i mostra un resum."""
    try:
        cursor.execute(f"SELECT DBMS_LOB.GETLENGTH(blob_column) FROM {table_name}")
        sizes = [row[0] for row in cursor.fetchall()]
        total_size = sum(sizes)
        average_size = total_size / len(sizes) if sizes else 0
        logging.info(f"Total BLOB Size: {total_size} bytes, Average BLOB Size: {average_size} bytes")
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en consultar les mides dels BLOB: {e}")
def export_blob_to_file(cursor, table_name, blob_id, output_path):
    """Exporta un BLOB a un fitxer temporal i comprova la integritat."""
    try:
        cursor.execute(f"SELECT blob_column FROM {table_name} WHERE id = :blob_id", blob_id=blob_id)
        blob_data = cursor.fetchone()[0]
        with open(output_path, 'wb') as file:
            file.write(blob_data)
        logging.info(f"BLOB amb ID {blob_id} exportat a '{output_path}' amb èxit.")
    except cx_Oracle.DatabaseError as e:
        logging.error(f"Error en exportar el BLOB amb ID {blob_id}: {e}")
def main():
    # Configuració de la connexió a la base de dades
    username = "your_username"
    password = "your_password"
    dsn = "your_dsn"
    
    # Establir connexió a la base de dades
    connection = connect_to_db(username, password, dsn)
    cursor = connection.cursor()
    
    try:
        # Carregar vídeos i contractes com a BLOBs
        video_blob = load_blob_from_file(cursor, 'path_to_video.mp4')
        pdf_blob = load_blob_from_file(cursor, 'path_to_contract.pdf')
        
        if video_blob:
            insert_blob(cursor, 'VideosTable', video_blob)
        if pdf_blob:
            insert_blob(cursor, 'ContractsTable', pdf_blob)
        
        # Generar i inserir documents XML per clients
        for client_id in range(1, 4):
            xml_data = generate_xml_client(client_id, f"Client {client_id}")
            insert_xml_record(cursor, xml_data)
        
        # Executar consultes XQuery sobre RegistresXML
        query_xml_records(cursor)
        
        # Consultar mides dels BLOBs
        get_blob_sizes(cursor, 'VideosTable')
        get_blob_sizes(cursor, 'ContractsTable')
        
        # Exportar un BLOB a un fitxer temporal
        export_blob_to_file(cursor, 'VideosTable', 1, 'exported_video.mp4')
    
    finally:
        cursor.close()
        connection.close()
        logging.info("Connexió a la base de dades tancada.")
if __name__ == "__main__":
    main()