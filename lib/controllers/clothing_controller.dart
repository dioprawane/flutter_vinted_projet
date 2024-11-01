import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing.dart'; // Importer le modèle Clothing
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ClothingController {
  final CollectionReference clothingCollection = FirebaseFirestore.instance.collection('vetements2');

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

  // Ajouter un nouveau vêtement dans Firestore
  Future<void> addNewClothing(Clothing clothingItem) async {
    await clothingCollection.add({
      'titre': clothingItem.titre,
      'taille': clothingItem.taille,
      'prix': clothingItem.prix,
      'image': clothingItem.image,
      'details': {
        'categorie': clothingItem.detailsCategorie,
        'image': clothingItem.detailsImage,
        'marque': clothingItem.detailsMarque,
      }
    });
  }

  // Appel à l'API pour obtenir la catégorie et l'image base64
  Future<Map<String, dynamic>> getCategoryAndImageBase64(File imageFile) async {
    final url = Uri.parse("https://cnn-api-clothing-4d8c986cc770.herokuapp.com/predict/");
    final request = http.MultipartRequest("POST", url);

    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception("Erreur lors de l'envoi de l'image à l'API");
    }
  }
}