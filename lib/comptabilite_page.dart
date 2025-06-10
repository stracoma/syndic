// comptabilite_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'comptabilite_service.dart';
import 'gardiens_page.dart';

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
    // S'assurer que les documents initiaux existent dans Firebase, sinon les créer avec 0.0
    await FirebaseFirestore.instance.collection('comptes').doc('cotisations').set({'montant': 0.0}, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('comptes').doc('solde').set({'montant': 0.0}, SetOptions(merge: true));

    final fraisGenerauxDocRef = FirebaseFirestore.instance.collection('comptes').doc('frais_generaux');
    final fraisGenerauxDocSnapshot = await fraisGenerauxDocRef.get();

    if (!fraisGenerauxDocSnapshot.exists) {
      await fraisGenerauxDocRef.set({'frais_autre_gardiens': 0.0});
    }

    // Recalculer les cotisations et le solde quand la page se charge
    await ComptabiliteService.updateCotisations();
    await ComptabiliteService.updateSolde();
  }

  // Fonction pour construire une carte d'affichage des comptes
  Widget _buildCompteCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Ajustement de la marge verticale
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: color), // Taille d'icône légèrement réduite mais toujours visible
            const SizedBox(width: 12), // Espacement réduit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16, // Taille de police légèrement réduite
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat.currency(locale: 'fr_FR', symbol: 'DH').format(amount)}',
                    style: const TextStyle(
                      fontSize: 22, // Taille de police principale ajustée
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNouvelleDepense(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController montantController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Dépense Générale'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView( // Ajout d'un scroll pour le contenu du dialogue si le clavier est présent
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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('solde').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildCompteCard('Solde Actuel', 0.0, Colors.green[800]!, Icons.account_balance_wallet);
                }
                final solde = (snapshot.data!['montant'] as num?)?.toDouble() ?? 0.0;
                return _buildCompteCard(
                  'Solde Actuel',
                  solde,
                  Colors.green[800]!,
                  Icons.account_balance_wallet,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('comptes').doc('cotisations').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return _buildCompteCard('Total Cotisations', 0.0, Colors.blue[800]!, Icons.money);
                      }
                      final cotisations = (snapshot.data!['montant'] as num?)?.toDouble() ?? 0.0;
                      return _buildCompteCard(
                        'Total Cotisations',
                        cotisations,
                        Colors.blue[800]!,
                        Icons.money,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('comptes').doc('frais_generaux').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return _buildCompteCard('Autres Dépenses', 0.0, Colors.red[800]!, Icons.money_off);
                      }
                      final autresDepenses = (snapshot.data!['frais_autre_gardiens'] as num?)?.toDouble() ?? 0.0;
                      return _buildCompteCard(
                        'Autres Dépenses',
                        autresDepenses,
                        Colors.red[800]!,
                        Icons.money_off,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('comptes').doc('depenses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildCompteCard('Salaires Gardiens', 0.0, Colors.orange[800]!, Icons.person_pin);
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                double totalSalairesGardiens = 0.0;

                if (data != null) {
                  for (int i = 1; i <= 3; i++) {
                    final gardienSommeRecueKey = 'gardien${i}_somme_recue';
                    totalSalairesGardiens += (data[gardienSommeRecueKey] as num?)?.toDouble() ?? 0.0;
                  }
                }

                return _buildCompteCard(
                  'Salaires Gardiens',
                  totalSalairesGardiens,
                  Colors.orange[800]!,
                  Icons.person_pin,
                );
              },
            ),

            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _addNouvelleDepense(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une Dépense Générale'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16), // Taille de texte du bouton
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GardiensPage()),
                    );
                  },
                  icon: const Icon(Icons.group),
                  label: const Text('Gérer les Dépenses des Gardiens'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16), // Taille de texte du bouton
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await ComptabiliteService.updateCotisations();
                      await ComptabiliteService.updateSolde();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comptabilité mise à jour !')), // Message mis à jour
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Mettre à jour Comptabilité'), // Texte du bouton mis à jour
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontSize: 16), // Taille de texte du bouton
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Historique des Transactions :',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Ajustement de la hauteur du SizedBox pour l'historique
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4, // Utiliser un pourcentage de la hauteur de l'écran
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ComptabiliteService.getTransactions(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final transactions = snapshot.data!.docs;
                      if (transactions.isEmpty) {
                        return const Center(child: Text('Aucune transaction enregistrée.'));
                      }
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final data = transaction.data() as Map<String, dynamic>;
                          final type = data['type'] ?? 'N/A';
                          final description = data['description'] ?? 'N/A';
                          final montant = (data['montant'] as num?)?.toDouble() ?? 0.0;
                          final date = (data['date'] as Timestamp?)?.toDate();

                          Color textColor = Colors.black87;
                          if (type == 'depense') {
                            textColor = Colors.red;
                          } else if (type == 'cotisation') {
                            textColor = Colors.green;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                type == 'depense' ? Icons.remove_circle : Icons.add_circle,
                                color: textColor,
                              ),
                              title: Text(
                                description,
                                style: TextStyle(color: textColor, fontSize: 15), // Taille de texte ajustée
                              ),
                              subtitle: Text(
                                date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Date inconnue',
                                style: const TextStyle(fontSize: 12), // Taille de texte ajustée
                              ),
                              trailing: Text(
                                '${NumberFormat.currency(locale: 'fr_FR', symbol: 'DH').format(montant)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  fontSize: 16, // Taille de texte ajustée
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
          ],
        ),
      ),
    );
  }
}