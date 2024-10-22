import 'dart:convert'; // Pour base64Decode
import 'package:flutter/material.dart';
import 'package:vinted_projet/controllers/panier_controller.dart';
import 'package:vinted_projet/models/panier.dart';
import '../widgets/header.dart'; // Importer le header
import '../widgets/menu.dart'; // Importer le menu

class PanierPage extends StatefulWidget {
  final String userId; // ID de l'utilisateur connecté

  const PanierPage({super.key, required this.userId});

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  final PanierController _panierController = PanierController(); // Initialiser le contrôleur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: 'Mon Panier'),
      body: StreamBuilder<List<Panier>>(
        stream: _panierController.getPaniers(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement du panier'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Votre panier est vide.'));
          }

          final panierList = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: panierList.length,
                  itemBuilder: (context, index) {
                    final item = panierList[index];
                    String imageBase64 = item.image;

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
                          // Optionnel : Gérer la navigation vers le détail du produit ici si nécessaire
                        }, // Naviguer vers la page de détail si nécessaire
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
                                            item.titre,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text('Taille : ${item.taille}'),
                                        Text('Prix : ${item.prix} €'),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.blueAccent), // Utiliser une croix pour la suppression
                                  onPressed: () {
                                    setState(() {
                                      _panierController.removeFromBasket(item.id); // Supprimer l'article du panier
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<double>(
                  future: _panierController.getTotalPrice(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final total = snapshot.data ?? 0.0;

                    return Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blueAccent,
                      ),
                      child: Text(
                      'Total : $total €',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const MenuWidget(currentIndex: 1), // Le menu avec l'index du panier
    );
  }
}