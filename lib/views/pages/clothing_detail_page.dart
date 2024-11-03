import 'package:flutter/material.dart';
import 'dart:convert'; // Pour base64Decode
import '../../controllers/clothing_controller.dart'; // Importer le contrôleur ClothingController
import '../../models/clothing.dart'; // Importer le modèle Clothing
import '../widgets/header.dart'; // Importer le header
import 'package:shared_preferences/shared_preferences.dart';

class ClothingDetailPage extends StatefulWidget {
  final Clothing clothingItem;

  const ClothingDetailPage({super.key, required this.clothingItem});

  @override
  ClothingDetailPageState createState() => ClothingDetailPageState();
}

class ClothingDetailPageState extends State<ClothingDetailPage> {
  final ClothingController _clothingController = ClothingController(); // Initialiser le contrôleur

  // Fonction pour ajouter l'article au panier
  Future<void> _addToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      await _clothingController.addToCart(userId, widget.clothingItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vêtement ajouté au panier')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur non connecté')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageBase64 = widget.clothingItem.detailsImage ?? widget.clothingItem.image;

    if (imageBase64.startsWith('data:image')) {
      imageBase64 = imageBase64.split(',')[1]; // Garder seulement la partie Base64
    }

    return Scaffold(
      appBar: const HeaderWidget(title: 'Détail du vêtement'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.memory(
                base64Decode(imageBase64), // Décoder et afficher l'image
                width: 400,
                height: 300,
                fit: BoxFit.contain, // Ajustement pour afficher l'image sans déformation
              ),
            ),
            const SizedBox(height: 20),
            Text('Titre : ${widget.clothingItem.detailsTitre ?? widget.clothingItem.titre}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Taille : ${widget.clothingItem.detailsTaille ?? widget.clothingItem.taille}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Prix : ${widget.clothingItem.detailsPrix ?? widget.clothingItem.prix} €', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Catégorie : ${widget.clothingItem.detailsCategorie ?? "Non spécifiée"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Marque : ${widget.clothingItem.detailsMarque ?? "Non spécifiée"}', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Retour à la page précédente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Couleur du bouton "Retour"
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text('Retour',
                    style: TextStyle(color: Colors.white))
                  // Mettre le texte de retour en blanc
                ),
                ElevatedButton.icon(
                  onPressed: _addToCart, // Appelle la fonction d'ajout au panier
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Couleur du bouton "Ajouter au panier"
                  ),
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: const Text('Ajouter au panier',
                    style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}