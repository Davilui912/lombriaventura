const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json()); // Para poder recibir JSON en las peticiones

// Configuración de la base de datos
const db = mysql.createConnection({
    host: 'localhost',
    user: 'lombriadmin',
    password: 'Lombriaventura*123',
    database: 'lombriaventura'
});

// Conectar a la base de datos
db.connect((err) => {
    if (err) {
        console.error('❌ Error conectando a MariaDB:', err);
        return;
    }
    console.log('✅ Conectado a MariaDB');
});

// ============================================
// ========== ENDPOINTS DE LA API =============
// ============================================

// -------- ENDPOINT DE PRUEBA --------
app.get('/api/test', (req, res) => {
    res.json({ message: 'API funcionando correctamente 🚀' });
});

// -------- REGISTRO DE USUARIO --------
app.post('/api/registro', (req, res) => {
    const { nombreUsuario, nombre, contrasena, edad, ciudad, genero, preguntaSeguridad, respuestaSeguridad } = req.body;

    // Verificar si el usuario ya existe
    const checkQuery = 'SELECT * FROM usuarios WHERE nombreUsuario = ?';
    db.query(checkQuery, [nombreUsuario], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Error en el servidor' });
        }
        if (results.length > 0) {
            return res.status(400).json({ error: 'El nombre de usuario ya está registrado' });
        }

        // Insertar el nuevo usuario
        const insertQuery = `INSERT INTO usuarios 
            (nombreUsuario, nombre, contrasena, edad, ciudad, genero, preguntaSeguridad, respuestaSeguridad) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
        
        db.query(insertQuery, [nombreUsuario, nombre, contrasena, edad, ciudad, genero, preguntaSeguridad, respuestaSeguridad], (err, result) => {
            if (err) {
                console.error(err);
                return res.status(500).json({ error: 'Error al registrar usuario' });
            }
            res.status(201).json({ 
                message: 'Usuario registrado exitosamente',
                nombreUsuario: nombreUsuario
            });
        });
    });
});

// -------- INICIO DE SESIÓN --------
app.post('/api/login', (req, res) => {
    const { nombreUsuario, contrasena } = req.body;

    const query = 'SELECT * FROM usuarios WHERE nombreUsuario = ? AND contrasena = ?';
    db.query(query, [nombreUsuario, contrasena], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Error en el servidor' });
        }
        if (results.length === 0) {
            return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
        }

        // ✅ Usuario autenticado
        const usuario = results[0];
        res.json({
            nombreUsuario: usuario.nombreUsuario,
            nombre: usuario.nombre,
            edad: usuario.edad,
            ciudad: usuario.ciudad,
            genero: usuario.genero,
            estrellas: usuario.estrellas,
            monedas: usuario.monedas
        });
    });
});

// -------- OBTENER DATOS DE UN USUARIO --------
app.get('/api/usuario/:nombreUsuario', (req, res) => {
    const { nombreUsuario } = req.params;

    const query = 'SELECT * FROM usuarios WHERE nombreUsuario = ?';
    db.query(query, [nombreUsuario], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Error en el servidor' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const usuario = results[0];
        res.json({
            nombreUsuario: usuario.nombreUsuario,
            nombre: usuario.nombre,
            edad: usuario.edad,
            ciudad: usuario.ciudad,
            genero: usuario.genero,
            estrellas: usuario.estrellas,
            monedas: usuario.monedas,
            fechaRegistro: usuario.fechaRegistro
        });
    });
});

// -------- OBTENER CONFIGURACIÓN (ej. API Key de Groq) --------
app.get('/api/config/:clave', (req, res) => {
    const { clave } = req.params;

    const query = 'SELECT valor FROM configuracion WHERE clave = ?';
    db.query(query, [clave], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Error en el servidor' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Configuración no encontrada' });
        }

        res.json({ valor: results[0].valor });
    });
});

// -------- INICIAR EL SERVIDOR --------
app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});