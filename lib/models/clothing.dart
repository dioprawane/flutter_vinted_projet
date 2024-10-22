
class Clothing {
  String id;
  String titre;
  String taille;
  double prix;
  String image;
  String? detailsCategorie;
  String? detailsImage;
  double? detailsPrix;
  String? detailsTaille;
  String? detailsTitre;
  String? detailsMarque;

  Clothing({
    required this.id,
    required this.titre,
    required this.taille,
    required this.prix,
    required this.image,
    this.detailsCategorie,
    this.detailsImage,
    this.detailsPrix,
    this.detailsTaille,
    this.detailsTitre,
    this.detailsMarque,
  });

  // Convertir un document Firebase en modèle Clothing
  factory Clothing.fromFirestore(Map<String, dynamic> data, String id) {
    return Clothing(
      id: id,
      titre: data['titre'] ?? '',
      taille: data['taille'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      detailsCategorie: data['details']?['categorie'],
      detailsImage: data['details']?['image'],
      detailsPrix: (data['details']?['prix'] ?? 0).toDouble(),
      detailsTaille: data['details']?['taille'],
      detailsTitre: data['details']?['titre'],
      detailsMarque: data['details']?['marque'],
    );
  }

  // Ajoutez la méthode copyWith
  Clothing copyWith({
    String? id,
    String? titre,
    String? taille,
    double? prix,
    String? image,
    String? detailsCategorie,
    String? detailsImage,
    double? detailsPrix,
    String? detailsTaille,
    String? detailsTitre,
    String? detailsMarque,
  }) {
    return Clothing(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      taille: taille ?? this.taille,
      prix: prix ?? this.prix,
      image: image ?? this.image,
      detailsCategorie: detailsCategorie ?? this.detailsCategorie,
      detailsImage: detailsImage ?? this.detailsImage,
      detailsPrix: detailsPrix ?? this.detailsPrix,
      detailsTaille: detailsTaille ?? this.detailsTaille,
      detailsTitre: detailsTitre ?? this.detailsTitre,
      detailsMarque: detailsMarque ?? this.detailsMarque,
    );
  }
}