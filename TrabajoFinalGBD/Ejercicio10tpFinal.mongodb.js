// Ejercicio 10 – Gestor Mongo DB
// a) Activar la base de datos "local" y luego imprimir las colecciones existentes.
use ('local')
db.getCollectionNames()

// b) Activar la base de datos "test" y luego imprimir las colecciones existentes.
use ('test')
db.getCollectionNames()

// c) Activar la base de datos "baseEjemplo2".
use ('baseEjemplo2')

// d) Mostrar las colecciones existentes en la base de datos "baseEjemplo2".
db.getCollectionNames()

// e) Crear otra colección llamada usuarios donde almacenar dos documentos con los 
// campos nombre y clave.

use ('baseEjemplo2');
db.createCollection('usuarios')

use ('baseEjemplo2');
item1 = {
    nombre : "usuario1",
    clave: "1234"
};

item2 = {
    nombre : "usuario2",
    clave  : "abcd"
};      

db.usuarios.insertMany([item1, item2]);
db.usuarios.find();

// f) Mostrar nuevamente las colecciones existentes en la base de datos "baseEjemplo2".

use ('baseEjemplo2');
db.getCollectionNames()

//  En la base pubs:
// g) Insertar 2 documentos en la colección clientes con '_id' no repetidos
use ('pubs')

item1 = {
    _id : 1,
    nombre : "Carlos Perez",
    email: "carlos@gmail.com",
};

item2 = {
    _id : 2,
    nombre : "Ana Gomez",
        email: "ana@gmail.com",
    
};    

db.clientes.insertMany([item1, item2]);

db.clientes.find();


// h) Intentar insertar otro documento con clave repetida.

// nos muestra un error porque el campo _id no puede repetirse.

db.clientes.insertOne({
    _id: 1,
    nombre: "Pedro Lopez",
    email: "pedro@gmail.com"
});


// i) Mostrar todos los documentos de la colección libros.

use("pubs")
db.createCollection("libros")

db.libros.insertMany([
    {
        titulo: "MongoDB Básico",
        autor: "Juan Perez",
        precio: 2500
    },
    {
        titulo: "Bases de Datos",
        autor: "Ana Gomez",
        precio: 3000
    }
])

db.libros.find()


// j) Crear una base de datos llamada "blog".
use ('blog')

// k) Agregar una colección llamada "posts" e insertar 1 documento con una estructura a 
// su elección.

db.createCollection("posts")

db.posts.insertOne({
    titulo: "Mi primer post",
    autor: "Juan Perez",
    contenido: "Este es un ejemplo de publicación en MongoDB."
    
})

db.posts.find()

// l) Mostrar todas las bases de datos actuales.
show dbs;

// m) Eliminar la colección "posts"
use ('blog');
db.posts.drop()


use('blog')
db.getCollectionNames()


//n) Eliminar la base de datos "blog" y mostrar las bases de datos existentes.
use ('blog');
db.dropDatabase()

show dbs;


