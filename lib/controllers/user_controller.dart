import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart'; // Importer le modèle User

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour récupérer un utilisateur par son ID
  Future<User?> getUserById(String userId) async {
    try {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return User.fromFirestore(userDoc.data()!, userDoc.id);
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
    }
    return null;
  }

  // Fonction pour mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'login': user.login,
        'password': user.password,
        'anniversaire': Timestamp.fromDate(user.anniversaire), // Conversion en Timestamp
        'adresse': user.adresse,
        'code_postal': user.codePostal,
        'ville': user.ville,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur : $e');
    }
  }

  // Fonction pour créer un nouvel utilisateur
  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'login': user.login,
        'password': user.password,
        'anniversaire': Timestamp.fromDate(user.anniversaire), // Conversion en Timestamp
        'adresse': user.adresse,
        'code_postal': user.codePostal,
        'ville': user.ville,
      });
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur : $e');
    }
  }
  
}