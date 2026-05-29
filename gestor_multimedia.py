import os
import cx_Oracle

USER = "usuari"
PASSWORD = "contrasenya"
DSN = "localhost/XEPDB1"

# Carpetes locals
CARPETA_VIDEOS = "videos"
CARPETA_PDFS = "contractes"

try:

    conn = cx_Oracle.connect(
        user=USER,
        password=PASSWORD,
        dsn=DSN
    )

    cursor = conn.cursor()

    print("Connexió establerta correctament.\n")

    print("===== CÀRREGA DE VÍDEOS =====")

    videos = [
        (1, "Video demostració producte 1", "video1.mp4", 120),
        (2, "Video demostració producte 2", "video2.mp4", 95)
    ]

    for producte_id, descripcio, nom_fitxer, durada in videos:

        ruta = os.path.join(CARPETA_VIDEOS, nom_fitxer)

        try:

            with open(ruta, "rb") as fitxer:
                dades_blob = fitxer.read()

            cursor.execute("""
                INSERT INTO VideosProducte
                (producte_id, descripcio, video, format, durada_segons)
                VALUES (:1, :2, :3, :4, :5)
            """, (
                producte_id,
                descripcio,
                dades_blob,
                "mp4",
                durada
            ))

            print(f"Vídeo {nom_fitxer} carregat correctament.")

        except Exception as e:
            print(f"Error carregant vídeo {nom_fitxer}: {e}")

    conn.commit()

    print()

    print("===== CÀRREGA DE CONTRACTES PDF =====")

    pdfs = [
        (1, "contracte1.pdf"),
        (2, "contracte2.pdf")
    ]

    for client_id, nom_fitxer in pdfs:

        ruta = os.path.join(CARPETA_PDFS, nom_fitxer)

        try:

            with open(ruta, "rb") as fitxer:
                dades_blob = fitxer.read()

            mida = len(dades_blob)

            cursor.execute("""
                INSERT INTO DocumentsContracte
                (client_id, contracte, tipus_document, mida_bytes)
                VALUES (:1, :2, :3, :4)
            """, (
                client_id,
                dades_blob,
                "pdf",
                mida
            ))

            print(f"PDF {nom_fitxer} carregat correctament.")

        except Exception as e:
            print(f"Error carregant PDF {nom_fitxer}: {e}")

    conn.commit()

    print()

    print("===== GENERACIÓ DOCUMENTS XML =====")

    clients = [1, 2]

    for client_id in clients:

        try:

            cursor.execute("""
                SELECT xml_client(:1)
                FROM dual
            """, [client_id])

            resultat = cursor.fetchone()

            if resultat:

                xml_data = resultat[0]

                cursor.execute("""
                    INSERT INTO RegistresXML(xml_data)
                    VALUES (:1)
                """, [xml_data])

                print(f"XML del client {client_id} guardat.")

        except Exception as e:
            print(f"Error generant XML client {client_id}: {e}")

    conn.commit()

    print()

    print("===== CONSULTA XQUERY: CLIENTS AMB > 1 DOCUMENT =====")

    cursor.execute("""
        SELECT
            XMLCAST(
                XMLQUERY('/Client/IdClient'
                PASSING xml_data
                RETURNING CONTENT)
                AS VARCHAR2(20)
            ) AS client_id
        FROM RegistresXML
        WHERE XMLEXISTS(
            '/Client[count(DocumentsContracte/Document) > 1]'
            PASSING xml_data
        )
    """)

    files = cursor.fetchall()

    for fila in files:
        print(f"Client amb múltiples documents: {fila[0]}")

    print()

    print("===== CONSULTA XQUERY: VÍDEOS PER FORMAT =====")

    cursor.execute("""
        SELECT format, COUNT(*) total
        FROM RegistresXML r,
             XMLTABLE(
                '/Videos/Video'
                PASSING r.xml_data
                COLUMNS
                    format VARCHAR2(20) PATH 'Format'
             )
        GROUP BY format
    """)

    files = cursor.fetchall()

    for fila in files:
        print(f"Format: {fila[0]} --> {fila[1]} vídeos")

    print()

    print("===== RESUM MIDA BLOBS =====")

    cursor.execute("""
        SELECT
            SUM(DBMS_LOB.GETLENGTH(video)),
            AVG(DBMS_LOB.GETLENGTH(video))
        FROM VideosProducte
    """)

    resultat = cursor.fetchone()

    total_videos = resultat[0] or 0
    mitjana_videos = resultat[1] or 0

    print(f"TOTAL BYTES VÍDEOS: {total_videos}")
    print(f"MITJANA BYTES VÍDEOS: {round(mitjana_videos, 2)}")

    print()

    cursor.execute("""
        SELECT
            SUM(DBMS_LOB.GETLENGTH(contracte)),
            AVG(DBMS_LOB.GETLENGTH(contracte))
        FROM DocumentsContracte
    """)

    resultat = cursor.fetchone()

    total_pdf = resultat[0] or 0
    mitjana_pdf = resultat[1] or 0

    print(f"TOTAL BYTES PDFS: {total_pdf}")
    print(f"MITJANA BYTES PDFS: {round(mitjana_pdf, 2)}")

    print()

    print("===== EXPORTACIÓ DE BLOBS =====")

    os.makedirs("exportats", exist_ok=True)

    cursor.execute("""
        SELECT producte_id, video
        FROM VideosProducte
    """)

    videos_exportats = cursor.fetchall()

    for producte_id, blob in videos_exportats:

        ruta_sortida = f"exportats/video_{producte_id}.mp4"

        with open(ruta_sortida, "wb") as fitxer:
            fitxer.write(blob.read())

        print(f"Vídeo exportat: {ruta_sortida}")

    print()

except cx_Oracle.DatabaseError as e:

    error, = e.args

    print("ERROR BASE DE DADES:")
    print(error.message)

except Exception as e:

    print("ERROR GENERAL:")
    print(e)

finally:

    try:
        cursor.close()
        conn.close()
        print("\nConnexió tancada.")

    except:
        pass