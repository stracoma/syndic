import 'package:cloud_firestore/cloud_firestore.dart';

class Personne {
  String nom;
  String prenom;
  int numero; // Ajout de l'attribut numero
  DateTime? moisPaye;

  Personne({required this.nom, required this.prenom, required this.numero, this.moisPaye});

  // Méthode pour créer une instance de Personne à partir d'une Map (utile pour Firestore)
  factory Personne.fromMap(Map<String, dynamic> data) {
    return Personne(
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      numero: data['numero']?.toInt() ?? 0, // Assure que numero est un int, avec une valeur par défaut de 0
      moisPaye: data['moisPaye'] != null ? (data['moisPaye'] as Timestamp).toDate() : null,
    );
  }

  // Méthode pour convertir une instance de Personne en Map (utile pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'numero': numero,
      'moisPaye': moisPaye,
    };
  }
}