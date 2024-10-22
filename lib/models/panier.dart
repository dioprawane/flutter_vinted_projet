import 'package:cloud_firestore/cloud_firestore.dart';

class Panier {
  String id; // ID du document Firestore
  String itemId; // ID de l'article ajouté au panier
  String titre; // Titre de l'article
  String taille; // Taille de l'article
  double prix; // Prix de l'article
  String image; // Lien ou base64 de l'image
  String userId; // ID de l'utilisateur

  Panier({
    required this.id,
    required this.itemId,
    required this.titre,
    required this.taille,
    required this.prix,
    required this.image,
    required this.userId,
  });

  // Convertir un document Firestore en modèle Panier
  factory Panier.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Panier(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      titre: data['titre'] ?? '',
      taille: data['taille'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  // Convertir un modèle Panier en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'titre': titre,
      'taille': taille,
      'prix': prix,
      'image': image,
      'userId': userId,
    };
  }

  // Méthode pour la copie avec des champs optionnels
  Panier copyWith({
    String? id,
    String? itemId,
    String? titre,
    String? taille,
    double? prix,
    String? image,
    String? userId,
  }) {
    return Panier(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      titre: titre ?? this.titre,
      taille: taille ?? this.taille,
      prix: prix ?? this.prix,
      image: image ?? this.image,
      userId: userId ?? this.userId,
    );
  }
}