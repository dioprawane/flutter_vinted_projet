import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importer intl pour le formatage des dates
import '../../controllers/user_controller.dart'; // Importer le contrôleur
import '../../models/user.dart'; // Importer le modèle
import 'login_page.dart'; // Importer la page de connexion
import '../widgets/menu.dart'; // Importer le menu
// Importer le header

class ProfileView extends StatefulWidget {
  final String userId; // ID de l'utilisateur à afficher

  const ProfileView({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final UserController _userController = UserController();
  User? _user; // Stocke l'utilisateur récupéré

  TextEditingController _anniversaireController = TextEditingController();
  TextEditingController _codePostalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser(); // Charger l'utilisateur lors de l'initialisation
  }

  // Fonction pour récupérer les informations de l'utilisateur
  Future<void> _fetchUser() async {
    User? user = await _userController.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _user = user;
        // Initialiser les valeurs des champs texte
        _anniversaireController.text = DateFormat('dd/MM/yyyy').format(user.anniversaire);
        _codePostalController.text = user.codePostal;
      });
    } else {
      setState(() {
        _user = User(
          id: widget.userId,
          login: '',
          password: '',
          anniversaire: DateTime.now(),
          adresse: '',
          codePostal: '',
          ville: '',
        );
      });
    }
  }

  // Fonction pour sauvegarder les modifications
  Future<void> _saveUser() async {
    if (_user != null) {
      await _userController.updateUser(_user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
    }
  }

  // Fonction pour la déconnexion
  void _logout() {
    setState(() {
      _user = null; // Réinitialiser l'utilisateur actuel à null
    });
    // Naviguer vers la page de connexion
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Fonction pour sélectionner une date d'anniversaire
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _user?.anniversaire ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _user!.anniversaire) {
      setState(() {
        _user = _user!.copyWith(anniversaire: picked);
        _anniversaireController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Mon profil',
            style: TextStyle(
              color: Colors.white, // Couleur blanche pour le texte
              fontWeight: FontWeight.bold, // Optionnel, pour un texte plus accentué
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Ajout du bouton "Valider" avec icône
          TextButton.icon(
            onPressed: _saveUser, // Enregistrer les modifications
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Valider',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator()) // Afficher un chargement pendant la récupération des données
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Login
                  TextField(
                    controller: TextEditingController(text: _user!.login),
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      prefixIcon: Icon(Icons.person), // Icône de login
                    ),
                    readOnly: true, // Le login est en lecture seule
                  ),
                  const SizedBox(height: 10),

                  // Mot de passe
                  TextField(
                    controller: TextEditingController(text: _user!.password),
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock), // Icône de mot de passe
                    ),
                    obscureText: true, // Masquer le mot de passe
                    onChanged: (value) {
                      _user = _user!.copyWith(password: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Anniversaire
                  TextField(
                    controller: _anniversaireController,
                    decoration: const InputDecoration(
                      labelText: 'Anniversaire',
                      prefixIcon: Icon(Icons.cake), // Icône d'anniversaire
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context), // Ouvrir le sélecteur de date
                  ),
                  const SizedBox(height: 10),

                  // Adresse
                  TextField(
                    controller: TextEditingController(text: _user!.adresse),
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.home), // Icône d'adresse
                    ),
                    onChanged: (value) {
                      _user = _user!.copyWith(adresse: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Code postal
                  TextField(
                    controller: _codePostalController,
                    decoration: const InputDecoration(
                      labelText: 'Code Postal',
                      prefixIcon: Icon(Icons.local_post_office), // Icône du code postal
                    ),
                    keyboardType: TextInputType.number, // Clavier numérique
                    onChanged: (value) {
                      _user = _user!.copyWith(codePostal: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Ville
                  TextField(
                    controller: TextEditingController(text: _user!.ville),
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      prefixIcon: Icon(Icons.location_city), // Icône de ville
                    ),
                    onChanged: (value) {
                      _user = _user!.copyWith(ville: value);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bouton Se déconnecter
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Couleur de fond bleue
                      ),
                      // Bouton avec texte blanc
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const MenuWidget(currentIndex: 2), // Ajouter le menu en bas de la page
    );
  }
}