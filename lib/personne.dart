// personne.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Personne {
  String? id;
  final String nom;
  final String prenom;
  final int numero;
  final DateTime? moisPaye;
  final DateTime? dateSuscription; // ✅ Ajout de la date d'inscription

  Personne({
    this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
    this.moisPaye,
    this.dateSuscription, // ✅ Ajout au constructeur
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'numero': numero,
      'moisPaye': moisPaye,
      'dateSuscription': dateSuscription, // ✅ Enregistrement dans Firebase
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
      dateSuscription: map['dateSuscription'] is Timestamp
          ? (map['dateSuscription'] as Timestamp).toDate()
          : null, // ✅ Gestion de la récupération
    );
  }
}
