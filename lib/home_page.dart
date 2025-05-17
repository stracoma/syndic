import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';
import 'lesFonctions.dart';

class MyHomePage extends StatelessWidget {
  final bool isAdmin;
  final String _adminPassword = "taiba25";

  MyHomePage({super.key, required this.isAdmin});

  final CollectionReference _personnesCollection =
  FirebaseFirestore.instance.collection('personnes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[300],
      appBar: AppBar(
        title: Text('Liste des personnes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: _personnesCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final personnes = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Personne.fromMap(data);
            }).toList()
              ..sort((a, b) => a.numero.compareTo(b.numero));

            return Column(
              children: [
                ...personnes.map((personne) => Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  child: ListTile(
                    title: Text('${personne.nom ?? ''} ${personne.prenom ?? ''}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Numéro: ${personne.numero}'),
                        Text(
                          'Dernier mois payé: ${personne.moisPaye != null ? "${personne.moisPaye!.month.toString().padLeft(2, '0')}/${personne.moisPaye!.year}" : "Non spécifié"}',
                        ),
                      ],
                    ),
                    trailing: isAdmin
                        ? IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => afficherDialoguePourEdition(
                        context: context,
                        motDePasseAdmin: _adminPassword,
                        personne: personne,
                      ),
                    )
                        : null,
                  ),
                )),
                SizedBox(height: 50),
              ],
            );
          },
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => afficherDialoguePourCreation(
          context: context,
          motDePasseAdmin: _adminPassword,
        ),
      )
          : null,
    );
  }
}
