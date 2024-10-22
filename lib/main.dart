import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Pour base64Decode
import 'views/pages/profile_page.dart'; // Importer la vue UserView
import 'views/pages/login_page.dart'; // Importer la vue LoginPage
import 'views/pages/panier_page.dart'; // Importer la vue LoginPage
import 'views/pages/clothing_list_page.dart'; // Importer la page de liste des vêtements
// Importer la page de détail des vêtements


// Fonction principale pour démarrer l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Classe principale de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIOP VINTED',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 191, 182, 182),
          ),
          bodyMedium: GoogleFonts.merriweather(),
        ),
      ),
      home: const LoginPage(),
      routes: {
        //'/profile': (context) => const UserProfilePage(), // Ajoute cette ligne pour la navigation
        '/login': (context) => LoginPage(),
        '/profile': (context) => ProfileView(userId: 'user1'),
        '/buy': (context) => const ClothingListPage(),
        '/cart': (context) => PanierPage(userId: 'user1'),
        //'/details': (context) => const ClothingDetailPage(clothingItem: null), // Usage en naviguant via ClothingItem
        //'/buy': (context) => const ClothingListPage(),
        //'/buy': (context) => const ClothingListPage(),
        //'/cart': (context) => const CartPage(), // Remplacer par la page Panier si tu l'as
      },
    );
  }
}

// Page d'accueil après connexion pour tester la navigation
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Text('Bienvenue sur la page suivante !'),
      ),
    );
  }
}

// Page pour afficher la liste des vêtements
/*class ClothingListPage extends StatefulWidget {
  const ClothingListPage({super.key});

  @override
  _ClothingListPageState createState() => _ClothingListPageState();
}

// Etat de la page de la liste des vêtements
class _ClothingListPageState extends State<ClothingListPage> {
  int _selectedIndex = 0; // Pour gérer l'état de la navigation

  // Liste des titres pour la BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    Text('Acheter'), // Page actuelle "Acheter"
    Text('Panier'),  // Page du Panier
    Text('Profil'),  // Page du Profil
  ];

  // Changer de page lors de la navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fonction pour récupérer la liste des vêtements depuis Firestore
  Stream<QuerySnapshot> _getClothingList() {
    return FirebaseFirestore.instance.collection('vetements').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acheter des vêtements'),
        // Arriere-plan de l'AppBar en bleu
        backgroundColor: Theme.of(context).colorScheme.blueAccent,
      ),
      body: _selectedIndex == 0
          ? StreamBuilder<QuerySnapshot>(
              stream: _getClothingList(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Erreur de chargement des vêtements'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Liste de vêtements
                final clothingList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: clothingList.length,
                  itemBuilder: (context, index) {
                    var clothingItem = clothingList[index];
                    String imageBase64 = clothingItem['image']; // Image encodée en base64

                    // Supprimer le préfixe si nécessaire
                    if (imageBase64.startsWith('data:image')) {
                      imageBase64 = imageBase64.split(',')[1]; // Garder seulement la partie Base64
                    }

                    return Card(child: ListTile(
                      leading: Image.memory(
                        base64Decode(imageBase64), // Décoder l'image base64
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      title: Text(clothingItem['titre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Taille : ${clothingItem['taille']}'),
                          Text('Prix : ${clothingItem['prix']} €'),
                        ],
                      ),
                      onTap: () {
                        // Critère #5 : Au clic, rediriger vers la page de détail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClothingDetailPage(clothingItem: clothingItem),
                          ),
                        );
                      },
                    ));
                  },
                );
              },
            )
          : _pages[_selectedIndex], // Autres pages (Panier, Profil)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // L'index actuel de la navigation
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
      ),
    );
  }
}

extension on ColorScheme {
  get blueAccent => Colors.blueAccent;
  get brightness => Brightness.light;
}

// Page de détail d'un vêtement
class ClothingDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot clothingItem;

  const ClothingDetailPage({super.key, required this.clothingItem});

  // Fonction pour ajouter l'article au panier
  Future<void> _addToCart(BuildContext context) async {
    // Exemple d'ajout dans Firestore dans la collection "panier" pour l'utilisateur 'user1'
    await FirebaseFirestore.instance.collection('panier').add({
      'userId': 'user1', // Remplacer par l'ID utilisateur actuel
      'itemId': clothingItem.id,
      'titre': clothingItem['details']['titre'],
      'taille': clothingItem['details']['taille'],
      'prix': clothingItem['details']['prix'],
      'image': clothingItem['details']['image'],
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vêtement ajouté au panier')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si le champ 'details' existe et s'il n'est pas vide
    var data = clothingItem.data() as Map<String, dynamic>?;  // Récupérer les données en tant que Map

    if (data == null || !data.containsKey('details') || data['details'] == null) {
      // Si 'details' n'existe pas ou est vide
      print('Le champ "details" est manquant ou vide pour cet article.');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détail du vêtement'),
        ),
        body: const Center(
          child: Text('Les détails de ce vêtement n\'existent pas.'),
        ),
      );
    }

    // Accéder aux détails
    var details = clothingItem['details'];

    // Vérifier que le champ 'image' et autres détails existent dans 'details'
    String? imageBase64 = details['image'];
    if (imageBase64 != null && imageBase64.startsWith('data:image')) {
      imageBase64 = imageBase64.split(',')[1]; // Garder seulement la partie Base64
    }

    // Récupérer les détails des vêtements qui ont des détails
    if (details == null) {
      return const Scaffold(
        body: Center(
          child: Text('Détails non disponibles'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(clothingItem['titre']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageBase64 != null)
              Center(
                child: Image.memory(
                  base64Decode(imageBase64), // Décoder et afficher l'image
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text('Titre : ${details['titre']}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Taille : ${details['taille']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Prix : ${details['prix']} €', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Catégorie : ${details['categorie']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Marque : ${details['marque']}', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 30),
            // Alignement des boutons "Retour" et "Ajouter au panier"
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Espacement entre les deux boutons
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Retour à la page précédente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Couleur du bouton "Retour"
                  ),
                  icon: const Icon(
                      Icons.arrow_back), // Icône pour le bouton "Retour"
                  label: const Text('Retour'), // Texte du bouton "Retour"
                ),
                ElevatedButton.icon(
                  onPressed: () => _addToCart(
                      context), // Appelle la fonction pour ajouter au panier
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Couleur du bouton "Ajouter au panier"
                  ),
                  icon: const Icon(Icons
                      .shopping_cart), // Icône pour le bouton "Ajouter au panier"
                  label: const Text(
                      'Ajouter au panier'), // Texte du bouton "Ajouter au panier"
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/