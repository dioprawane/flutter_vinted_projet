import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Permet de personnaliser le titre

  const HeaderWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Couleur du texte
          ),
        ),
      ),
      // mettre le button de profil en blanc
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.blueAccent, // Arrière-plan bleu
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Hauteur par défaut de l'AppBar
}