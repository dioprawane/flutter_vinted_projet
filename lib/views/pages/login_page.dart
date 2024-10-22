import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Si vous avez un contrôleur de gestion des utilisateurs
import '../widgets/header.dart'; // Importer le HeaderWidget

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

    // Vérifiez si les champs sont vides naviguez vers la page suivante
    if (login.isEmpty && password.isEmpty) {
      Navigator.pushNamed(context, '/buy');
      return;
    }

    // Vérifiez si les champs sont vides
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
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
        // Si l'utilisateur existe, rediriger vers la page suivante (ici, la page des vêtements)
        Navigator.pushNamed(context, '/buy');
      } else {
        // Si l'utilisateur n'existe pas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ou mot de passe incorrect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Center(
          child: Text(
            'Connexion',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),*/
      appBar: const HeaderWidget(title: 'DIOP VINTED'), // Utiliser le widget Header
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
