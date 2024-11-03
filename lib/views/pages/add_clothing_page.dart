import 'dart:io';
import 'dart:convert'; // Import pour la conversion en base64
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../controllers/clothing_controller.dart'; // Importer le contrôleur ClothingController
import '../../models/clothing.dart'; // Importer le modèle Clothing
import 'package:permission_handler/permission_handler.dart';
import '../widgets/header.dart'; // Importer le widget HeaderWidget

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

  // Fonction pour convertir l'image en base64
  Future<void> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    setState(() {
      _imageBase64 = base64Encode(bytes);
    });
  }

  // Fonction pour sélectionner une image et la convertir en base64
  Future<void> _pickImage() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          (await Permission.manageExternalStorage.status.isGranted)) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedImage = File(result.files.single.path!);
          });

          // Convertir l'image en base64 localement
          await _convertImageToBase64(_selectedImage!);

          // Lancer la prédiction automatiquement après la sélection de l'image
          await _fetchCategory();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Permission refusée pour accéder aux fichiers."),
            ),
          );
        }
      }
    }
  }

  // Fonction pour obtenir uniquement la catégorie depuis l'API
  Future<void> _fetchCategory() async {
    if (_selectedImage == null) return;
    try {
      final result = await _clothingController.getCategoryAndImageBase64(_selectedImage!);
      if (mounted) {
        setState(() {
          _category = result["predicted_class"];
        });
      }
    } catch (e) {
      print("Erreur : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'envoi de l'image à l'API : $e")),
        );
      }
    }
  }

  // Fonction pour valider et ajouter un nouveau vêtement
  Future<void> _submitForm() async {
    if (_titleController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedImage == null ||
        _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Veuillez remplir tous les champs et ajouter une image")),
      );
      return;
    }

    final newClothing = Clothing(
      id: '',
      titre: _titleController.text,
      taille: _sizeController.text,
      prix: double.parse(_priceController.text),
      image: _imageBase64 ?? '', // Utiliser le base64 généré localement
      detailsCategorie: _category, // Prédit par l'API
      detailsImage: null, // Laisser à null par défaut
      detailsMarque: _brandController.text,
      detailsPrix: double.parse(_priceController.text), // Laisser à null par défaut
      detailsTaille: null, // Laisser à null par défaut
      detailsTitre: null, // Laisser à null par défaut
    );

    await _clothingController.addNewClothing(newClothing);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vêtement ajouté avec succès")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: "Ajouter un vêtement"),
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