// comptabilite_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'comptabilite_service.dart';

class ComptabilitePage extends StatefulWidget {
  const ComptabilitePage({super.key});

  @override
  State<ComptabilitePage> createState() => _ComptabilitePageState();
}

class _ComptabilitePageState extends State<ComptabilitePage> {

  @override
  void initState() {
    super.initState();
    _initializeComptabiliteData();
  }

  Future<void> _initializeComptabiliteData() async {
    await FirebaseFirestore.instance.collection('comptes').doc('cotisations').set({'montant': 0.0}, SetOptions(merge: true));
    // S'assurer que le document 'depenses' existe avec 'montant' pour les "autres dépenses"
    await FirebaseFirestore.instance.collection('comptes').doc('depenses').set({'montant': 0.0}, SetOptions(merge: true));
    // S'assurer que le document 'depensesGardiens' existe avec 'montant' pour le total des gardiens
    await FirebaseFirestore.instance.collection('comptes').doc('depensesGardiens').set({'montant': 0.0}, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('comptes').doc('solde').set({'montant': 0.0}, SetOptions(merge: true));

    await ComptabiliteService.updateCotisations();
    // Nous appelons updateSolde() pour mettre à jour le solde global
    // La mise à jour des montants individuels de dépenses sera gérée par les pages d'écriture
    await ComptabiliteService.updateSolde();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptabilité'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte Solde Actuel
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('solde').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final solde = snapshot.data!['montant'] ?? 0.0;
                return _buildCompteCard(
                  'Solde Actuel',
                  solde,
                  Colors.green[800]!,
                  Icons.account_balance_wallet,
                );
              },
            ),
            const SizedBox(height: 16),

            // Total Cotisations sur sa propre ligne
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('cotisations').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final cotisations = snapshot.data!['montant'] ?? 0.0;
                return _buildCompteCard(
                  'Total Cotisations',
                  cotisations,
                  Colors.blue[700]!,
                  Icons.payments,
                );
              },
            ),
            const SizedBox(height: 16),

            // Autres Dépenses sur sa propre ligne - CORRIGÉ pour lire 'depenses'
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('depenses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                // Assurez-vous de lire le champ 'montant' du document 'depenses'
                final depenses = snapshot.data!['montant'] ?? 0.0;
                return _buildCompteCard(
                  'Autres Dépenses',
                  depenses,
                  Colors.orange[700]!,
                  Icons.shopping_cart,
                );
              },
            ),
            const SizedBox(height: 16),

            // Dépenses Gardiens sur sa propre ligne - CORRIGÉ pour lire 'depensesGardiens'
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('depensesGardiens').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                // Assurez-vous de lire le champ 'montant' du document 'depensesGardiens'
                final depensesGardiens = snapshot.data!['montant'] ?? 0.0;
                return _buildCompteCard(
                  'Dépenses Gardiens',
                  depensesGardiens,
                  Colors.red[700]!,
                  Icons.security,
                );
              },
            ),
            const SizedBox(height: 16),

            // Liste des transactions
            Expanded( // La ListView a besoin d'un Expanded ou d'une hauteur contrainte quand elle est dans une Column et qu'elle n'est pas le seul enfant.
              // Cependant, si le parent est SingleChildScrollView, Expanded ne fonctionne pas comme on veut.
              // On utilise shrinkWrap et NeverScrollableScrollPhysics pour laisser le SingleChildScrollView gérer le scroll.
              child: StreamBuilder<QuerySnapshot>(
                stream: ComptabiliteService.getTransactions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final transactions = snapshot.data!.docs;
                  if (transactions.isEmpty) {
                    return const Center(child: Text('Aucune transaction enregistrée.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true, // Très important pour que ListView fonctionne dans un SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Empêche ListView d'avoir son propre scroll
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index].data() as Map<String, dynamic>;
                      final type = transaction['type'] ?? 'N/A';
                      final description = transaction['description'] ?? 'N/A';
                      final montant = transaction['montant'] ?? 0.0;
                      final date = (transaction['date'] as Timestamp?)?.toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            type == 'depense' ? Icons.remove_circle : Icons.add_circle,
                            color: type == 'depense' ? Colors.red : Colors.green,
                          ),
                          title: Text(description),
                          subtitle: Text(date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Date inconnue'),
                          trailing: Text(
                            '${type == 'depense' ? '-' : '+'}${montant.toStringAsFixed(2)} DH',
                            style: TextStyle(
                              color: type == 'depense' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDepenseDialog(context),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCompteCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(2)} DH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDepenseDialog(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController montantController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Dépense'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (DH)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ComptabiliteService.addDepense(
                  montant: double.parse(montantController.text),
                  description: descriptionController.text,
                );
                await ComptabiliteService.updateSolde();
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}