import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';

class CreerPersonne extends StatelessWidget {
  final Personne? personne;

  const CreerPersonne({super.key, this.personne});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nomController =
    TextEditingController(text: personne?.nom ?? '');
    final TextEditingController prenomController =
    TextEditingController(text: personne?.prenom ?? '');
    final TextEditingController numeroController = TextEditingController(
        text: personne?.numero != null ? personne!.numero.toString() : '');

    // Contrôleur pour le mois payé
    DateTime moisPaye = personne?.moisPaye ?? DateTime.now();
    final TextEditingController moisPayeController = TextEditingController(
        text: "${moisPaye.day}/${moisPaye.month}/${moisPaye.year}");

    return Scaffold(
      appBar: AppBar(
        title: Text(personne == null ? 'Créer une personne' : 'Modifier ${personne!.nom}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: prenomController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: numeroController,
              decoration: InputDecoration(labelText: 'Numéro'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Mois payé avec un bouton pour sélectionner la date
            TextField(
              controller: moisPayeController,
              decoration: InputDecoration(labelText: 'Mois payé'),
              readOnly: true, // Rendre le champ non éditable directement
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: moisPaye,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  moisPaye = selectedDate;
                  moisPayeController.text = "${moisPaye.day}/${moisPaye.month}/${moisPaye.year}";
                }
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String nom = nomController.text.trim();
                final String prenom = prenomController.text.trim();
                final int? numero = int.tryParse(numeroController.text.trim());

                if (nom.isEmpty || prenom.isEmpty || numero == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs correctement.')),
                  );
                  return;
                }

                final data = {
                  'nom': nom,
                  'prenom': prenom,
                  'numero': numero,
                  'moisPaye': moisPaye,
                };

                final collection = FirebaseFirestore.instance.collection('personnes');
                String message;

                if (personne == null) {
                  await collection.add(data);
                  message = 'Personne créée avec succès.';

                  // Effacer les champs
                  nomController.clear();
                  prenomController.clear();
                  numeroController.clear();
                  moisPayeController.clear();
                } else {
                  final snapshot = await collection
                      .where('numero', isEqualTo: personne!.numero)
                      .limit(1)
                      .get();

                  if (snapshot.docs.isNotEmpty) {
                    await snapshot.docs.first.reference.update(data);
                    message = 'Modifications enregistrées.';
                  } else {
                    message = 'Aucune personne trouvée à modifier.';
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

                await Future.delayed(Duration(seconds: 1));
                Navigator.pop(context);
              },
              child: Text(personne == null ? 'Créer' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
