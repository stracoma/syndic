// firebaseService.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';

final CollectionReference personnesCollection =
FirebaseFirestore.instance.collection('personnes');

// Ajouter une personne
Future<void> ajouterPersonne(Personne personne) async {
  await personnesCollection.add(personne.toMap());
}

// Modifier une personne
Future<void> modifierPersonne(Personne personne) async {
  if (personne.id != null) {
    await personnesCollection.doc(personne.id).update(personne.toMap());
  }
}

// Supprimer une personne
Future<void> supprimerPersonne(String id) async {
  await personnesCollection.doc(id).delete();
}

// Récupérer toutes les personnes
Stream<List<Personne>> recupererPersonnes() {
  return personnesCollection.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Personne.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
}
