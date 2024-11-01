import 'dart:convert'; // Pour base64Decode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinted_projet/controllers/panier_controller.dart';
import 'package:vinted_projet/models/panier.dart';
import '../widgets/header.dart'; // Importer le header
import '../widgets/menu.dart'; // Importer le menu

class PanierPage extends StatefulWidget {
  const PanierPage({super.key});

  @override
  PanierPageState createState() => PanierPageState();
}

class PanierPageState extends State<PanierPage> {
  final PanierController _panierController = PanierController(); // Initialiser le contrôleur
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Récupérer l'ID utilisateur depuis les préférences partagées
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: 'Mon Panier'),
      body: userId == null
          ? const Center(child: CircularProgressIndicator()) // Chargement pendant la récupération de l'ID utilisateur
          : StreamBuilder<List<Panier>>(
              stream: _panierController.getPaniers(userId!),
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
                            imageBase64 = imageBase64.split(',')[1];
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                // Optionnel : Gérer la navigation vers le détail du produit ici si nécessaire
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 130,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: AspectRatio(
                                            aspectRatio: 1.0,
                                            child: Image.memory(
                                              base64Decode(imageBase64),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
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
                                        icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                        onPressed: () {
                                          setState(() {
                                            _panierController.removeFromBasket(item.id);
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
                        future: _panierController.getTotalPrice(userId!),
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
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          );
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
