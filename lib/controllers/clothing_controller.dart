import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing.dart'; // Importer le modèle Clothing

class ClothingController {
  final CollectionReference clothingCollection = FirebaseFirestore.instance.collection('vetements');

  // Récupérer la liste des vêtements depuis Firestore
  Stream<List<Clothing>> getClothingList() {
    return clothingCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Clothing.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Ajouter un vêtement au panier
  Future<void> addToCart(String userId, Clothing clothingItem) async {
    await FirebaseFirestore.instance.collection('panier').add({
      'userId': userId,
      'itemId': clothingItem.id,
      'titre': clothingItem.titre,
      'taille': clothingItem.taille,
      'prix': clothingItem.prix,
      'image': clothingItem.image,
    });
  }

  // Supprimer un vêtement du panier (optionnel si nécessaire)
  Future<void> removeFromCart(String itemId) async {
    await FirebaseFirestore.instance.collection('panier').doc(itemId).delete();
  }
}