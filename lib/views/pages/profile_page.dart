import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importer intl pour le formatage des dates
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/user_controller.dart'; // Importer le contrôleur
import '../../models/user.dart'; // Importer le modèle
import 'login_page.dart'; // Importer la page de connexion
import 'add_clothing_page.dart';
import '../widgets/menu.dart'; // Importer le menu

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  final UserController _userController = UserController();
  User? _user; // Stocke l'utilisateur récupéré

  final TextEditingController _anniversaireController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser(); // Charger l'utilisateur lors de l'initialisation
  }

  // Fonction pour récupérer l'ID utilisateur de shared_preferences
  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Fonction pour récupérer les informations de l'utilisateur
  Future<void> _fetchUser() async {
    String? userId = await _getUserId();
    if (userId != null) {
      User? user = await _userController.getUserById(userId);
      if (user != null) {
        if (mounted) {
          setState(() {
            _user = user;
            _anniversaireController.text =
                DateFormat('dd/MM/yyyy').format(user.anniversaire);
            _codePostalController.text = user.codePostal;
          });
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  // Fonction pour sauvegarder les modifications
  Future<void> _saveUser() async {
    if (_user != null) {
      await _userController.updateUser(_user!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
      }
    }
  }

  // Fonction pour la déconnexion
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(
        'userId'); // Supprimer l'ID de l'utilisateur de shared_preferences

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton.icon(
            onPressed: _saveUser,
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
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: TextEditingController(text: _user!.login),
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      prefixIcon: Icon(Icons.person),
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: TextEditingController(text: _user!.password),
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      _user = _user!.copyWith(password: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _anniversaireController,
                    decoration: const InputDecoration(
                      labelText: 'Anniversaire',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: TextEditingController(text: _user!.adresse),
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.home),
                    ),
                    onChanged: (value) {
                      _user = _user!.copyWith(adresse: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _codePostalController,
                    decoration: const InputDecoration(
                      labelText: 'Code Postal',
                      prefixIcon: Icon(Icons.local_post_office),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _user = _user!.copyWith(codePostal: value);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: TextEditingController(text: _user!.ville),
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (value) {
                      _user = _user!.copyWith(ville: value);
                    },
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddClothingPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Ajouter un nouveau vêtement',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const MenuWidget(currentIndex: 2),
    );
  }
}