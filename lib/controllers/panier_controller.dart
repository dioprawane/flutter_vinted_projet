import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/panier.dart';

class PanierController {
  final CollectionReference _basketCollection =
      FirebaseFirestore.instance.collection('panier');

  // Récupérer les articles du panier d'un utilisateur
  Stream<List<Panier>> getPaniers(String userId) {
    return _basketCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Panier.fromFirestore(doc))
            .toList());
  }

  // Ajouter un article au panier
  Future<void> addToBasket(Panier item) async {
    try {
      await _basketCollection.add(item.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout au panier : $e');
    }
  }

  // Supprimer un article du panier
  Future<void> removeFromBasket(String itemId) async {
    try {
      await _basketCollection.doc(itemId).delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'article du panier : $e');
    }
  }

  // Calculer le total des prix du panier d'un utilisateur
  Future<double> getTotalPrice(String userId) async {
    double total = 0.0;
    QuerySnapshot snapshot = await _basketCollection
        .where('userId', isEqualTo: userId)
        .get();
    for (var doc in snapshot.docs) {
      total += (doc['prix'] ?? 0).toDouble();
    }
    return total;
  }
}