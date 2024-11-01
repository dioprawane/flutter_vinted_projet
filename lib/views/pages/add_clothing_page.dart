import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/clothing_controller.dart'; // Importer le contrôleur ClothingController
import '../../models/clothing.dart'; // Importer le modèle Clothing
import 'package:permission_handler/permission_handler.dart';
class AddClothingPage extends StatefulWidget {
  @override
  AddClothingPageState createState() => AddClothingPageState();
}

class AddClothingPageState extends State<AddClothingPage> {
  final _clothingController = ClothingController();
  final _titleController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();

  File? _selectedImage;
  String? _category;
  String? _imageBase64;

  // Fonction pour sélectionner une image depuis la galerie
  /*Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      _fetchCategoryAndImageBase64();
    }
  }*/
  // Fonction pour sélectionner une image depuis la galerie avec gestion des permissions
  // Fonction pour sélectionner une image depuis un dossier avec gestion des permissions
// Fonction pour sélectionner une image depuis un dossier avec gestion des permissions
  Future<void> _pickImage() async {
    // Demander explicitement la permission de stockage
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // Ouvrir le file picker pour sélectionner un fichier image
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'], // Extensions de fichiers autorisées
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
        // Appeler la fonction pour obtenir la catégorie et l'image en base64
        _fetchCategoryAndImageBase64();
      }
    } else {
      if (mounted) {
        // Vérifiez si le widget est toujours monté
        // Affichez un message à l'utilisateur si la permission est refusée
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Permission refusée pour accéder aux fichiers.")),
        );
      }
    }
  }

  // Fonction pour obtenir la catégorie et l'image en base64 depuis l'API
  Future<void> _fetchCategoryAndImageBase64() async {
    if (_selectedImage == null) return;
    try {
      final result = await _clothingController.getCategoryAndImageBase64(_selectedImage!);
      setState(() {
        _category = result["predicted_class"];
        _imageBase64 = result["image_base64"];
      });
    } catch (e) {
      print("Erreur : $e");
    }
  }

  // Fonction pour valider et ajouter un nouveau vêtement
  Future<void> _submitForm() async {
    if (_titleController.text.isEmpty || _sizeController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null || _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs et ajouter une image")),
      );
      return;
    }

    final newClothing = Clothing(
      id: '',
      titre: _titleController.text,
      taille: _sizeController.text,
      prix: double.parse(_priceController.text),
      image: _imageBase64 ?? '',
      detailsCategorie: _category,
      detailsImage: _imageBase64,
      detailsMarque: _brandController.text,
    );

    await _clothingController.addNewClothing(newClothing);

    if (mounted) {
      // Vérifiez si le widget est toujours monté
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vêtement ajouté avec succès")),
      );
    }

    if (mounted) {
      // Vérifiez si le widget est toujours monté
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un vêtement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Titre"),
            ),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(labelText: "Taille"),
            ),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: "Marque"),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: "Prix"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!, width: 100, height: 100)
                    : Container(width: 100, height: 100, color: Colors.grey[200]),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Choisir une image"),
                ),
              ],
            ),
            if (_category != null) Text("Catégorie détectée : $_category"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
