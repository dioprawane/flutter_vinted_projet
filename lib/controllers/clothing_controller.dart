import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clothing.dart'; // Importer le modèle Clothing
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
        'prix': clothingItem.detailsPrix,
        'taille': clothingItem.detailsTaille,
        'titre': clothingItem.detailsTitre,
      }
    });
  }

  // Appel à l'API pour obtenir la catégorie et l'image base64
  Future<Map<String, dynamic>> getCategoryAndImageBase64(File imageFile) async {
    final url = Uri.parse(
        "https://cnn-api-clothing-4d8c986cc770.herokuapp.com/predict/");
    final request = http.MultipartRequest("POST", url);

    // Vérifiez le type MIME du fichier
    print("Type MIME du fichier : ${lookupMimeType(imageFile.path)}");

    request.files.add(await http.MultipartFile.fromPath(
      "file",
      imageFile.path,
      contentType: MediaType.parse(
          lookupMimeType(imageFile.path) ?? 'application/octet-stream'),
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        final responseData = await response.stream.bytesToString();
        print(
            "Erreur de l'API avec statut ${response.statusCode} : $responseData");
        throw Exception(
            "Erreur lors de l'envoi de l'image à l'API, code ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la requête API : $e");
      rethrow;
    }
  }

}