// comptabilite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ComptabiliteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // NOTE: _montantParMoisParGardien n'est plus strictement nécessaire ici pour updateSolde
  // car nous lisons directement les sommes cumulées, mais peut rester pour d'autres usages.
  // static const double _montantParMoisParGardien = 3000.0;

  static Future<void> updateCotisations() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('personnes').get();
      double total = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['dateSuscription'] != null && data['moisPaye'] != null) {
          DateTime debut = (data['dateSuscription'] as Timestamp).toDate();
          DateTime fin = (data['moisPaye'] as Timestamp).toDate();

          // Calcul corrigé pour le nombre de mois payés
          final int totalMonthsDebut = debut.year * 12 + debut.month;
          final int totalMonthsFin = fin.year * 12 + fin.month;

          final int monthsPaid = totalMonthsFin - totalMonthsDebut + 1;
          final int safeMonthsPaid = monthsPaid > 0 ? monthsPaid : 0;

          total += 300.0 * safeMonthsPaid; // 300 DH par mois
        }
      }

      await _firestore.collection('comptes').doc('cotisations').set({
        'montant': total
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la mise à jour des cotisations: $e');
      rethrow;
    }
  }

  static Future<void> addDepense({
    required double montant,
    required String description,
  }) async {
    // Enregistrer la transaction individuelle
    await _firestore.collection('transactions').add({
      'type': 'depense',
      'montant': montant,
      'description': description,
      'date': FieldValue.serverTimestamp(),
    });

    // Mettre à jour le montant total des frais_autre_gardiens dans le nouveau document
    await _firestore.collection('comptes').doc('frais_generaux').set({
      'frais_autre_gardiens': FieldValue.increment(montant),
    }, SetOptions(merge: true)); // Utiliser merge pour créer le document s'il n'existe pas et ajouter le champ
  }

  static Stream<QuerySnapshot> getTransactions() {
    return _firestore.collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> updateSolde() async {
    try {
      final cotisationsDoc = await _firestore.collection('comptes').doc('cotisations').get();
      final depensesGardiensDoc = await _firestore.collection('comptes').doc('depenses').get(); // Contient gardienX_somme_recue
      final fraisGenerauxDoc = await _firestore.collection('comptes').doc('frais_generaux').get(); // Nouveau document pour les frais généraux

      final double cotisations = (cotisationsDoc.data()?['montant'] as num?)?.toDouble() ?? 0.0;

      // Récupérer le montant général des autres dépenses depuis le nouveau document
      final double autresDepenses = (fraisGenerauxDoc.data()?['frais_autre_gardiens'] as num?)?.toDouble() ?? 0.0;

      // Calculer le total des dépenses des gardiens en utilisant les champs numériques 'gardienX_somme_recue'
      double totalGardiensDepenses = 0.0;
      final Map<String, dynamic>? depensesGardiensData = depensesGardiensDoc.data();

      if (depensesGardiensData != null) {
        for (int i = 1; i <= 3; i++) {
          final gardienSommeRecueKey = 'gardien${i}_somme_recue';
          totalGardiensDepenses += (depensesGardiensData[gardienSommeRecueKey] as num?)?.toDouble() ?? 0.0;
        }
      }

      // Calculer le total des dépenses : autres dépenses + toutes les dépenses des gardiens cumulées
      final double totalDepenses = autresDepenses + totalGardiensDepenses;

      final double solde = cotisations - totalDepenses;

      await _firestore.collection('comptes').doc('solde').set({
        'montant': solde
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de la mise à jour du solde: $e');
      rethrow;
    }
  }
}