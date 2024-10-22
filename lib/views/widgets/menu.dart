import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final int currentIndex ;
  const MenuWidget({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Par défaut, l'index est 0 (lors du démarrage)
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/buy'); // Aller à la page "Acheter"
        } else if (index == 1) {
          Navigator.pushNamed(context, '/cart'); // Aller à la page "Panier"
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile'); // Aller à la page "Profil"
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Acheter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Panier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
