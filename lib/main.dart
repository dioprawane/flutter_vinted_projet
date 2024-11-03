import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Pour base64Decode
import 'views/pages/profile_page.dart'; // Importer la vue UserView
import 'views/pages/login_page.dart'; // Importer la vue LoginPage
import 'views/pages/panier_page.dart'; // Importer la vue LoginPage
import 'views/pages/clothing_list_page.dart'; // Importer la page de liste des vêtements
// Importer la page de détail des vêtements

// URL de votre API
const String apiUrl = 'https://cnn-api-clothing-4d8c986cc770.herokuapp.com/';

// Fonction principale pour démarrer l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lancez une requête GET vers votre API
  await fetchServerData();

  runApp(const MyApp());
}

// Classe principale de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId'); // Vérifie si un userId est stocké
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Affichage de chargement
        }

        bool isLoggedIn = snapshot.data ?? false;
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
          home: isLoggedIn ? const ClothingListPage() : const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/profile': (context) => ProfileView(),
            '/buy': (context) => const ClothingListPage(),
            '/cart': (context) => PanierPage(),
          },
        );
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

// Fonction pour envoyer une requête GET
Future<void> fetchServerData() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      print("Réponse de l'API : ${response.body}");
    } else {
      print("Erreur lors de la requête : ${response.statusCode}");
    }
  } catch (e) {
    print("Erreur de connexion à l'API : $e");
  }
}