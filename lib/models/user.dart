import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String login;
  String password;
  DateTime anniversaire; // Changement pour DateTime
  String adresse;
  String codePostal;
  String ville;

  User({
    required this.id,
    required this.login,
    required this.password,
    required this.anniversaire,
    required this.adresse,
    required this.codePostal,
    required this.ville,
  });

  // Convertir un document Firebase en modèle User
  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      login: data['login'] ?? '',
      password: data['password'] ?? '',
      anniversaire: (data['anniversaire'] as Timestamp).toDate(), // Conversion du Timestamp en DateTime
      adresse: data['adresse'] ?? '',
      codePostal: data['code_postal'] ?? '',
      ville: data['ville'] ?? '',
    );
  }

  // Méthode copyWith pour permettre les modifications
  User copyWith({
    String? id,
    String? login,
    String? password,
    DateTime? anniversaire, // Type changé en DateTime
    String? adresse,
    String? codePostal,
    String? ville,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      anniversaire: anniversaire ?? this.anniversaire,
      adresse: adresse ?? this.adresse,
      codePostal: codePostal ?? this.codePostal,
      ville: ville ?? this.ville,
    );
  }
}