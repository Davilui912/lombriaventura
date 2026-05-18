import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'chat_ia.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

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
            _buildMenuButton('Juegos', Icons.games, AppTheme.azulCielo, () {}),
            _buildMenuButton('Cuestionarios', Icons.quiz, AppTheme.verde, () {}),
            _buildMenuButton('Historias', Icons.book, AppTheme.cafe, () {}),
            _buildMenuButton('Mi Composta 📸', Icons.camera_alt, AppTheme.amarillo, () {}),
            _buildMenuButton('Pregúntale\na Lola 🤖', Icons.chat, AppTheme.azulCielo, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatIAScreen()),
                );
              }),
            _buildMenuButton('Tienda', Icons.shopping_cart, AppTheme.verde, () {}),
            _buildMenuButton('Mis Logros', Icons.star, AppTheme.cafe, () {}),
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
}