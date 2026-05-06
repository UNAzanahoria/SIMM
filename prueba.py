#ejemplo de ejercicio
from tinydb import TinyDB

db = TinyDB('datos.json')

db.insert({'nombre': 'Laura', 'edad': 28})
db.insert_multiple([
    {'nombre': 'Pedro', 'edad': 32},
    {'nombre': 'Ana', 'edad': 22}
])

print(db.all())

from tinydb import Query

Persona = Query()
resultado = db.search(Persona.edad >= 25)
print(resultado)

resultado = db.search((Persona.edad >= 25) & (Persona.nombre == 'Pedro'))

resultado = db.search((Persona.nombre == 'Pedro') | (Persona.nombre == 'Ana'))

db.insert({
    'nombre': 'Carlos',
    'direccion': {
        'ciudad': 'Madrid',
        'codigo_postal': 28001
    }
})

resultado = db.search(Persona.direccion.test(lambda d: d['ciudad'] == 'Madrid'))

db.update({'edad': 29}, Persona.nombre == 'Laura')

db.update(lambda d: d.update({'edad': d['edad'] + 1}), Persona.nombre == 'Pedro')

db.remove(Persona.nombre == 'Ana')

usuarios = db.table('usuarios')
usuarios.insert({'nombre': 'Lucía'})

pedidos = db.table('pedidos')
pedidos.insert({'producto': 'Libro', 'precio': 12.99})

#ejercicio 1

from tinydb import TinyDB, Query

#Creo base datos
db = TinyDB('estudiantes.json')

#Insertp 3 estudiantes
db.insert_multiple([
    {'nombre': 'Laura', 'edad': 19, 'curso': 'Matemáticas'},
    {'nombre': 'Pedro', 'edad': 22, 'curso': 'Historia'},
    {'nombre': 'Ana', 'edad': 25, 'curso': 'Informática'}
])

#Busco estudiantes > 20 años
Estudiante = Query()
resultado = db.search(Estudiante.edad > 20)

print(resultado)

print("//" * 20)

#ejercio 2

#Creo la base de datos
db = TinyDB('estudiantes.json')

#nserto estudiantes con subdocumento "direccion"
db.insert_multiple([
    {
        'nombre': 'Laura',
        'edad': 21,
        'curso': 'Matemáticas',
        'direccion': {
            'ciudad': 'Madrid',
            'codigo_postal': 28001
        }
    },
    {
        'nombre': 'Pedro',
        'edad': 23,
        'curso': 'Historia',
        'direccion': {
            'ciudad': 'Sevilla',
            'codigo_postal': 41001
        }
    },
    {
        'nombre': 'Ana',
        'edad': 19,
        'curso': 'Informática',
        'direccion': {
            'ciudad': 'Valencia',
            'codigo_postal': 46001
        }
    }
])

#Creo objeto de consulta
Estudiante = Query()

#Actualizo la ciudad de Pedro (por ejemplo, a Barcelona)
db.update(
    {'direccion': {'ciudad': 'Barcelona', 'codigo_postal': 8001}},
    Estudiante.nombre == 'Pedro'
)

#Verifico cambios
resultado = db.search(Estudiante.nombre == 'Pedro')
print(resultado)

print("//" * 20)

#ejercicio 3

db = TinyDB('tienda.json')

# Crear tablas
clientes = db.table('clientes')
pedidos = db.table('pedidos')

# Insertar clientes
clientes.insert_multiple([
    {'id_cliente': 1, 'nombre': 'Laura'},
    {'id_cliente': 2, 'nombre': 'Pedro'},
    {'id_cliente': 3, 'nombre': 'Ana'}
])

# Insertar pedidos relacionados por id_cliente
pedidos.insert_multiple([
    {'id_pedido': 101, 'id_cliente': 1, 'producto': 'Libro', 'precio': 12.99},
    {'id_pedido': 102, 'id_cliente': 1, 'producto': 'Cuaderno', 'precio': 3.50},
    {'id_pedido': 103, 'id_cliente': 2, 'producto': 'Bolígrafo', 'precio': 1.20}
])

# Buscar pedidos de un cliente por su nombre
Cliente = Query()
Pedido = Query()

nombre_buscar = 'Pedro'

# Obtener el cliente
cliente = clientes.get(Cliente.nombre == nombre_buscar)

if cliente:
    id_cliente = cliente['id_cliente']
    pedidos_cliente = pedidos.search(Pedido.id_cliente == id_cliente)

    print(f"Pedidos de {nombre_buscar}:")
    print(pedidos_cliente)
else:
    print("Cliente no encontrado")