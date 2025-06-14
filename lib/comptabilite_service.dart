// comptabilite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ComptabiliteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateCotisations() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('personnes').get();
      double total = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['dateSuscription'] != null && data['moisPaye'] != null) {
          DateTime debut = (data['dateSuscription'] as Timestamp).toDate();
          DateTime fin = (data['moisPaye'] as Timestamp).toDate();

          final int totalMonthsDebut = debut.year * 12 + debut.month;
          final int totalMonthsFin = fin.year * 12 + fin.month;

          final int monthsPaid = totalMonthsFin - totalMonthsDebut + 1;
          final int safeMonthsPaid = monthsPaid > 0 ? monthsPaid : 0;

          total += 300.0 * safeMonthsPaid;
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

    // Mettre à jour le montant total des AUTRES DÉPENSES dans le document 'depenses'
    await _firestore.collection('comptes').doc('depenses').set({
      'montant': FieldValue.increment(montant), // Incrémente le montant total des autres dépenses
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot> getTransactions() {
    return _firestore.collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> updateSolde() async {
    try {
      final cotisationsDoc = await _firestore.collection('comptes').doc('cotisations').get();
      // Lire le montant total des "autres dépenses" depuis le document 'depenses'
      final depensesDoc = await _firestore.collection('comptes').doc('depenses').get();
      // Lire le montant total des "dépenses gardiens" depuis le document 'depensesGardiens'
      final depensesGardiensDoc = await _firestore.collection('comptes').doc('depensesGardiens').get();

      final double cotisations = (cotisationsDoc.data()?['montant'] as num?)?.toDouble() ?? 0.0;
      // Récupérer le montant total des autres dépenses
      final double autresDepenses = (depensesDoc.data()?['montant'] as num?)?.toDouble() ?? 0.0;
      // Récupérer le montant total des dépenses des gardiens
      final double totalGardiensDepenses = (depensesGardiensDoc.data()?['montant'] as num?)?.toDouble() ?? 0.0;

      // Calculer le total des dépenses : autres dépenses + total des dépenses des gardiens
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