import 'package:cloud_firestore/cloud_firestore.dart';

class Personne {
  String? id;
  final String nom;
  final String prenom;
  final int numero;
  final DateTime? moisPaye;

  Personne({
    this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
    this.moisPaye,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'numero': numero,
      'moisPaye': moisPaye, // Envoi direct du DateTime (pas de toIso8601String)
    };
  }

  factory Personne.fromMap(Map<String, dynamic> map, String id) {
    return Personne(
      id: id,
      nom: map['nom']?.toString() ?? '',
      prenom: map['prenom']?.toString() ?? '',
      numero: map['numero'] ?? 0,
      moisPaye: map['moisPaye'] is Timestamp
          ? (map['moisPaye'] as Timestamp).toDate()
          : null,
    );
  }
}
