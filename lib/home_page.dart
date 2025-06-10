// home_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'personne.dart';
import 'lesFonctions.dart';
import 'comptabilite_service.dart'; // Assurez-vous d'importer ce service

class MyHomePage extends StatelessWidget {
  final bool isAdmin;
  final String _adminPassword = "taiba25"; // Récupéré de votre accueil_page

  MyHomePage({super.key, required this.isAdmin});

  final CollectionReference _personnesCollection =
  FirebaseFirestore.instance.collection('personnes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text('Liste des personnes'),
        backgroundColor: Colors.blue[800], // Uniformisation des couleurs
        foregroundColor: Colors.white, // Couleur du texte du titre
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>( // Pas besoin de SingleChildScrollView si le contenu est juste un ListView
        stream: _personnesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucune personne enregistrée. Cliquez sur le bouton "+" pour en ajouter une.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final personnes = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            try {
              return Personne.fromMap(data, doc.id);
            } catch (e) {
              // Gérer les erreurs de parsing si des données sont mal formées
              print('Erreur de conversion de personne: $e, Données: $data');
              rethrow; // Relancer l'erreur ou retourner une Personne par défaut
            }
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0), // Padding général pour la liste
            itemCount: personnes.length,
            itemBuilder: (context, index) {
              final personne = personnes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Marge pour chaque carte
                elevation: 3, // Légère élévation pour un effet de profondeur
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bords arrondis
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Padding interne de la carte
                  child: ListTile(
                    contentPadding: EdgeInsets.zero, // Pas de padding supplémentaire pour le ListTile
                    title: Text(
                      '${personne.nom} ${personne.prenom}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Taille de police pour le nom
                        color: Colors.blueGrey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4), // Espacement après le nom
                        Text(
                          'Numéro: ${personne.numero}',
                          style: const TextStyle(fontSize: 14), // Taille de police
                        ),
                        Text(
                          'Dernier mois payé: ${personne.moisPaye != null ? DateFormat.yMMMM('fr_FR').format(personne.moisPaye!) : "Non spécifié"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Date d\'inscription: ${personne.dateSuscription != null ? DateFormat.yMMMM('fr_FR').format(personne.dateSuscription!) : "Non spécifiée"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: isAdmin
                        ? Row( // Utiliser un Row pour aligner les icônes horizontalement
                      mainAxisSize: MainAxisSize.min, // Occupe l'espace minimal
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo, size: 24), // Taille de l'icône
                          onPressed: () => afficherDialoguePourEdition(
                            context: context,
                            motDePasseAdmin: _adminPassword,
                            personne: personne,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 24), // Icône de suppression
                          onPressed: () async {
                            // Ajouter un dialogue de confirmation avant suppression
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
                                content: Text('Voulez-vous vraiment supprimer ${personne.nom} ${personne.prenom} ?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await FirebaseFirestore.instance.collection('personnes').doc(personne.id).delete();
                              await ComptabiliteService.updateCotisations(); // Mettre à jour les cotisations après suppression
                              await ComptabiliteService.updateSolde(); // Mettre à jour le solde
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${personne.nom} supprimé !')),
                              );
                            }
                          },
                        ),
                      ],
                    )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        onPressed: () => afficherDialoguePourCreation(
          context: context,
          motDePasseAdmin: _adminPassword,
        ),
        child: const Icon(Icons.add, size: 28), // Taille de l'icône du FAB
      )
          : null,
    );
  }
}