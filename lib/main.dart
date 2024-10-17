import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:convert'; // Pour base64Decode

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
    );
  }
}

// Page de connexion
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction de connexion en vérifiant Firestore
  Future<void> _login() async {
    String login = _loginController.text.trim();
    String password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      // Critère #6 : Si les champs sont vides
      print('Veuillez remplir les champs');
      return;
    }

    try {
      // Requête dans Firestore pour vérifier si l'utilisateur existe
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('login', isEqualTo: login)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        // Critère #5 : Si l'utilisateur existe, rediriger vers la page suivante
        print('Utilisateur trouvé');
        Navigator.push(
          context,
          //MaterialPageRoute(builder: (context) => HomePage()),
          MaterialPageRoute(builder: (context) => const ClothingListPage()),
        );
      } else {
        // Si l'utilisateur n'existe pas
        print('Utilisateur non trouvé ou mot de passe incorrect');
      }
    } catch (e) {
      print('Erreur lors de la connexion : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'DIOP VINTED',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Login',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _login, // Appelle la fonction de login
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
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
class ClothingListPage extends StatefulWidget {
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

                    return ListTile(
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
                    );
                  },
                );
              },
            )
          : _pages[_selectedIndex], // Autres pages (Panier, Profil)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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

    /*String imageBase64 = clothingItem['image']; // Récupérer l'image en base64

    // Supprimer le préfixe si nécessaire
    if (imageBase64.startsWith('data:image')) {
      imageBase64 = imageBase64.split(',')[1]; // Garder seulement la partie Base64
    }*/

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
                  width: 350,
                  height: 350,
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
          ],
        ),
      ),
    );
  }
}
