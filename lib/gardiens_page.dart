// gardiens_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'comptabilite_service.dart'; // Importez le service de comptabilité

// Classe pour représenter un gardien (pour l'affichage en bas)
class Gardien {
  final int id;
  final String nomComplet;

  Gardien({required this.id, required this.nomComplet});
}

class GardiensPage extends StatefulWidget {
  const GardiensPage({super.key});

  @override
  State<GardiensPage> createState() => _GardiensPageState();
}

class _GardiensPageState extends State<GardiensPage> {
  // Une Map pour stocker l'état de chaque checkbox (clé: 'Mois_NumeroGardien')
  final Map<String, bool> _checkboxStates = {};

  // Liste des gardiens pour l'affichage en bas
  final List<Gardien> _gardiensList = [
    Gardien(id: 1, nomComplet: 'Marc Leblanc'),
    Gardien(id: 2, nomComplet: 'Samadi Mohamed'),
    Gardien(id: 3, nomComplet: 'Bahari Soumaki'),
  ];

  late int _selectedYear;
  final double _montantParMoisParGardien = 3000.0; // 3000 DH par mois par gardien coché

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year; // Initialise l'année à l'année actuelle
    _loadCheckboxStatesFromFirebase(_selectedYear);
  }

  Future<void> _loadCheckboxStatesFromFirebase(int year) async {
    // Réinitialiser les états des checkboxes à false par défaut pour la nouvelle année/chargement
    setState(() {
      _checkboxStates.clear();
      for (int monthIndex = 0; monthIndex < 12; monthIndex++) {
        for (int gardienIndex = 1; gardienIndex <= 3; gardienIndex++) {
          final checkboxKey = '${monthIndex}_$gardienIndex';
          _checkboxStates[checkboxKey] = false;
        }
      }
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('comptes')
          .doc('depenses')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;

        for (int gardienIndex = 1; gardienIndex <= 3; gardienIndex++) {
          final gardienFieldKey = 'gardien$gardienIndex'; // ex: 'gardien1'

          if (data.containsKey(gardienFieldKey) && data[gardienFieldKey] is Map<String, dynamic>) {
            final Map<String, dynamic> gardienDataForYears = data[gardienFieldKey];

            // Vérifier si des données existent pour l'année sélectionnée
            if (gardienDataForYears.containsKey('$year') && gardienDataForYears['$year'] is List) {
              final List<dynamic> gardienMonths = gardienDataForYears['$year'];
              setState(() {
                for (int monthIndex = 0; monthIndex < 12; monthIndex++) {
                  final checkboxKey = '${monthIndex}_$gardienIndex';
                  if (monthIndex < gardienMonths.length) {
                    _checkboxStates[checkboxKey] = gardienMonths[monthIndex] ?? false;
                  } else {
                    _checkboxStates[checkboxKey] = false; // Par défaut si le tableau n'a pas 12 mois
                  }
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des états des checkboxes: $e');
      // Les checkboxes restent à false comme initialisé au début de la fonction en cas d'erreur.
    }
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear += delta;
    });
    _loadCheckboxStatesFromFirebase(_selectedYear); // Recharger les états pour la nouvelle année
  }

  Future<void> _saveGardiensDepenses() async {
    // Préparer les données mensuelles par gardien pour l'année sélectionnée
    final Map<String, List<bool>> gardiensMonthlyDataForCurrentYear = {
      'gardien1': List.filled(12, false),
      'gardien2': List.filled(12, false),
      'gardien3': List.filled(12, false),
    };

    for (int monthIndex = 0; monthIndex < 12; monthIndex++) {
      for (int gardienIndex = 1; gardienIndex <= 3; gardienIndex++) {
        final checkboxKey = '${monthIndex}_$gardienIndex';
        final gardienSpecificKey = 'gardien$gardienIndex'; // ex: 'gardien1' pour les tableaux

        bool isChecked = _checkboxStates[checkboxKey] ?? false;
        gardiensMonthlyDataForCurrentYear[gardienSpecificKey]![monthIndex] = isChecked;
      }
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('comptes').doc('depenses');
      final docSnapshot = await docRef.get();
      Map<String, dynamic> existingData = docSnapshot.data() ?? {};

      // Mise à jour des tableaux de booléens (historique mensuel par année)
      // La structure sera: { gardien1: { 2025: [bool, bool, ...], 2024: [...] }, ... }
      Map<String, dynamic> updatePayload = {};

      for (int gardienIndex = 1; gardienIndex <= 3; gardienIndex++) {
        final gardienFieldKey = 'gardien$gardienIndex'; // Clé pour le champ principal du gardien (qui contient les années)

        // Assurez-vous que le champ du gardien existe et est une Map
        if (!existingData.containsKey(gardienFieldKey) || existingData[gardienFieldKey] is! Map<String, dynamic>) {
          existingData[gardienFieldKey] = <String, dynamic>{};
        }

        // Mettre à jour les données de l'année sélectionnée pour ce gardien
        (existingData[gardienFieldKey] as Map<String, dynamic>)['$_selectedYear'] =
        gardiensMonthlyDataForCurrentYear[gardienFieldKey];

        // Ajouter la structure mise à jour au payload
        updatePayload[gardienFieldKey] = existingData[gardienFieldKey];

        // --- Recalculer le total 'gardienX_somme_recue' pour ce gardien à travers TOUTES les années ---
        double totalForThisGardien = 0.0;
        if (existingData[gardienFieldKey] is Map<String, dynamic>) {
          (existingData[gardienFieldKey] as Map<String, dynamic>).forEach((yearKey, monthlyBooleans) {
            if (monthlyBooleans is List) {
              for (var isPaid in monthlyBooleans) { // Utilisation de var pour gérer les types dynamiques
                if (isPaid == true) { // Assurez-vous que c'est un vrai booléen true
                  totalForThisGardien += _montantParMoisParGardien;
                }
              }
            }
          });
        }
        updatePayload['gardien${gardienIndex}_somme_recue'] = totalForThisGardien;
      }

      await docRef.set(updatePayload, SetOptions(merge: true));

      await ComptabiliteService.updateSolde(); // Mettre à jour le solde après l'enregistrement

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dépenses des gardiens enregistrées et solde mis à jour !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
      );
      print('Erreur lors de l\'enregistrement des dépenses des gardiens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> monthNames = List.generate(12, (index) {
      return DateFormat.MMMM('fr_FR').format(DateTime(_selectedYear, index + 1));
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => _changeYear(-1),
            ),
            Text(
              '$_selectedYear',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => _changeYear(1),
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 100),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text('1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            Column(
              children: List.generate(12, (monthIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          monthNames[monthIndex],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(3, (gardienIndex) {
                            final gardienNumber = gardienIndex + 1;
                            final checkboxKey = '${monthIndex}_$gardienNumber';
                            return Checkbox(
                              value: _checkboxStates[checkboxKey] ?? false,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _checkboxStates[checkboxKey] = newValue!;
                                });
                                print('Année: $_selectedYear, Mois: ${monthNames[monthIndex]}, Gardien: $gardienNumber, État: $newValue');
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveGardiensDepenses,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les dépenses des gardiens'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 40),

            const Text(
              'Liste des Gardiens :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._gardiensList.map((gardien) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${gardien.id}- ${gardien.nomComplet}',
                style: const TextStyle(fontSize: 16),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}