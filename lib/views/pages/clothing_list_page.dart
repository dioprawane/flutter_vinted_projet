import 'package:flutter/material.dart';
import 'dart:convert'; // Pour base64Decode
import '../../controllers/clothing_controller.dart'; // Importer le contrôleur ClothingController
import '../../models/clothing.dart'; // Importer le modèle Clothing
import 'clothing_detail_page.dart'; // Importer la page ClothingDetailPage
import '../widgets/header.dart'; // Importer le header
import '../widgets/menu.dart'; // Importer le menu

class ClothingListPage extends StatefulWidget {
  const ClothingListPage({super.key});

  @override
  ClothingListPageState createState() => ClothingListPageState();
}

class ClothingListPageState extends State<ClothingListPage> {
  final ClothingController _clothingController = ClothingController(); // Initialiser le contrôleur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: 'Acheter des vêtements'),
      body: StreamBuilder<List<Clothing>>(
        stream: _clothingController.getClothingList(), // Utiliser le contrôleur pour obtenir la liste
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des vêtements'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Liste de vêtements
          final clothingList = snapshot.data!;

          return ListView.builder(
            itemCount: clothingList.length,
            itemBuilder: (context, index) {
              var clothingItem = clothingList[index];
              String imageBase64 = clothingItem.image;

              // Supprimer le préfixe si nécessaire
              if (imageBase64.startsWith('data:image')) {
                imageBase64 = imageBase64.split(',')[1]; // Garder seulement la partie Base64
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 16.0), // Espacement autour de la carte
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClothingDetailPage(clothingItem: clothingItem),
                      ),
                    );
                  }, // Naviguer vers la page de détail au clic
                  child: Card(
                    elevation: 5, // Légère élévation pour un effet de profondeur
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Coins arrondis pour un effet stylé
                    ),
                    child: SizedBox(
                      height: 130, // Augmentation de la hauteur de la carte
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0), // Coins arrondis
                              child: AspectRatio(
                                aspectRatio: 1.0, // Ratio 1:1 pour éviter la déformation
                                child: Image.memory(
                                  base64Decode(imageBase64), // Décoder l'image base64
                                  fit: BoxFit.contain, // Garder l'image dans sa taille originale
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2, // Ajuster la proportion de la section texte par rapport à l'image
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center, // Centrer le texte verticalement
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0), // Espacement en dessous du titre
                                    child: Text(
                                      clothingItem.titre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text('Taille : ${clothingItem.taille}'),
                                  Text('Prix : ${clothingItem.prix} €'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const MenuWidget(currentIndex: 0),
    );
  }
  
}