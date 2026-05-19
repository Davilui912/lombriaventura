import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'chat_ia.dart';
import 'diario/mi_composta.dart';
import 'juegos/clasifica_residuos.dart';
import 'juegos/alimenta_lola.dart';
import 'juegos/memorama.dart';
import 'logros.dart';
import 'tienda/catalogo.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Hola, Eco Héroe! 🪱'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          children: [
            _buildMenuButton('Conoce a las\nlombrices', Icons.bug_report, AppTheme.verde, () {}),
            _buildMenuButton('¿Qué es la\nlombricomposta?', Icons.recycling, AppTheme.cafe, () {}),
            _buildMenuButton('Aprende a\nhacerla', Icons.construction, AppTheme.amarillo, () {}),
            _buildMenuButton('Juegos', Icons.games, AppTheme.azulCielo, () {
              _mostrarMenuJuegos(context);
            }),
            _buildMenuButton('Cuestionarios', Icons.quiz, AppTheme.verde, () {}),
            _buildMenuButton('Historias', Icons.book, AppTheme.cafe, () {}),
            _buildMenuButton('Mi Composta 📸', Icons.camera_alt, AppTheme.amarillo, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MiCompostaScreen()),
              );
            }),
            _buildMenuButton('Pregúntale\na Lola 🤖', Icons.chat, AppTheme.azulCielo, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatIAScreen()),
              );
            }),
            _buildMenuButton('Tienda', Icons.shopping_cart, AppTheme.verde, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TiendaScreen()),
                );
              }),
            _buildMenuButton('Mis Logros', Icons.star, AppTheme.cafe, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogrosScreen()),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenuJuegos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎮 Elige un juego'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOpcionJuego(
              context,
              '♻️ Clasifica residuos',
              'Arrastra al contenedor correcto',
              Icons.recycling,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClasificaResiduosScreen())),
            ),
            const SizedBox(height: 10),
            _buildOpcionJuego(
              context,
              '🪱 Alimenta a Lola',
              'Dale la comida correcta',
              Icons.restaurant,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlimentaLolaScreen())),
            ),
            const SizedBox(height: 10),
            _buildOpcionJuego(
              context,
              '🧩 Rompecabezas',
              'Arma la composta (próximamente)',
              Icons.extension,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Próximamente! 🚧')),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildOpcionJuego(
              context,
              '🧠 Memorama',
              'Encuentra las parejas',
              Icons.memory,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoramaScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionJuego(BuildContext context, String titulo, String descripcion, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9EE),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.verde.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.verde, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(descripcion, style: const TextStyle(fontSize: 12, color: AppTheme.cafe)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.cafe),
          ],
        ),
      ),
    );
  }
}