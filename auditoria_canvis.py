import cx_Oracle
from datetime import datetime, timedelta

try:
    conn = cx_Oracle.connect(
        user="SYSTEM", #no se si es SYSTEM o otro usuario
        password="SYSTEM", #no se si es SYSTEM o otra
        dsn="la dsn que no me acuerdo"
    )

    cursor = conn.cursor()

    print("Conexión a la base de datos.")

    try:
        cursor.execute("""
            INSERT INTO Comandes(id_comanda, data_comanda, descompte)
            VALUES (:1, :2, :3)
        """, (1001, datetime.now(), 10))

        conn.commit()
        print("Comanda vàlida inserida correctament.")

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print("Error:", error.message)

    try:
        data_futura = datetime.now() + timedelta(days=5)

        cursor.execute("""
            INSERT INTO Comandes(id_comanda, data_comanda, descompte)
            VALUES (:1, :2, :3)
        """, (1002, data_futura, 15))

        conn.commit()

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print("Error trigger data futura:")
        print(error.message)

    print()

    try:
        cursor.execute("""
            UPDATE Productes
            SET stock = stock - 9999
            WHERE id_producte = 1
        """)

        conn.commit()

    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print("Error trigger stock:")
        print(error.message)

    print()

    actualitzacions = [
        (20, 1001),
        (5, 1001),
        (12, 1001)
    ]

    for nou_descompte, id_comanda in actualitzacions:

        try:
            cursor.execute("""
                UPDATE Comandes
                SET descompte = :1
                WHERE id_comanda = :2
            """, (nou_descompte, id_comanda))

            conn.commit()

            print(f"Comanda {id_comanda} actualitzada a descompte {nou_descompte}%")

        except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.message)

    print()

    cursor.execute("""
        SELECT
            comanda_id,
            descompte_antic,
            descompte_nou,
            data_modificacio
        FROM LogsDescomptes
        ORDER BY data_modificacio
    """)

    registres = cursor.fetchall()

    for registre in registres:

        comanda_id = registre[0]
        antic = registre[1]
        nou = registre[2]
        data_mod = registre[3]

        diferencia = nou - antic

        if diferencia > 0:
            tipus = "INCREMENT"
        else:
            tipus = "REDUCCIÓ"

        print(f"""
Data: {data_mod}
Comanda: {comanda_id}
Descompte antic: {antic}%
Descompte nou: {nou}%
Diferència: {abs(diferencia)}% ({tipus})
----------------------------------------
""")

except cx_Oracle.DatabaseError as e:

    error, = e.args
    print("Error de connexió o base de dades:")
    print(error.message)

finally:


    try:
        cursor.close()
        conn.close()
        print("\nConnexió tancada.")

    except:
        pass