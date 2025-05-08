import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';
import 'creerPersonne.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Affichage des Membres',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _personnesCollection =
  FirebaseFirestore.instance.collection('personnes');
  final TextEditingController _passwordController = TextEditingController();
  final String _adminPassword = "admin";
  int? _selectedNumero;
  Personne? _selectedPersonne;

  @override
  void initState() {
    super.initState();
  }

  Personne? _getPersonne(int numero) {
    try {
      return lespersonnes.firstWhere((personne) => personne.numero == numero);
    } catch (e) {
      return null;
    }
  }

  void _afficherPersonne() async {
    if (_selectedNumero != null) {
      final snapshot = await _personnesCollection
          .where('numero', isEqualTo: _selectedNumero)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _selectedPersonne = Personne(
            nom: data['nom'],
            prenom: data['prenom'],
            numero: data['numero'],
            moisPaye: data['moisPaye'] != null
                ? (data['moisPaye'] as Timestamp).toDate()
                : null,
          );
        });
      } else {
        setState(() {
          _selectedPersonne = null;
        });
      }
    }
  }

  Future<void> _modifierMoisPaye(BuildContext context) async {
    if (_selectedPersonne == null) return;

    final bool? isPasswordValid = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mot de passe requis"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Mot de passe"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _adminPassword) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mot de passe incorrect."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                _passwordController.clear();
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );

    if (isPasswordValid == true) {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedPersonne!.moisPaye ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('fr', 'FR'),
      );

      if (pickedDate != null) {
        try {
          await _personnesCollection
              .where('numero', isEqualTo: _selectedPersonne!.numero)
              .limit(1)
              .get()
              .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final docId = snapshot.docs.first.id;
              _personnesCollection.doc(docId).update({'moisPaye': pickedDate});
            }
          });

          setState(() {
            _selectedPersonne!.moisPaye = pickedDate;
          });
        } catch (e) {
          print("Erreur de mise à jour de Firestore: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur de mise à jour: $e"),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations du Membre'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _personnesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  List<Personne> personnes = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Personne(
                      nom: data['nom'],
                      prenom: data['prenom'],
                      numero: data['numero'],
                      moisPaye: data['moisPaye'] != null
                          ? (data['moisPaye'] as Timestamp).toDate()
                          : null,
                    );
                  }).toList();

                  List<int> numeros =
                  personnes.map((personne) => personne.numero).toList();

                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Sélectionner un numéro',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedNumero,
                    items: numeros.map((numero) {
                      return DropdownMenuItem<int>(
                        value: numero,
                        child: Text(numero.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedNumero = newValue;
                        _selectedPersonne = null;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _afficherPersonne,
                child: const Text('Afficher'),
              ),
              const SizedBox(height: 20),
              if (_selectedPersonne != null) ...[
                Text('Nom: ${_selectedPersonne!.nom}'),
                const SizedBox(height: 10),
                Text('Prénom: ${_selectedPersonne!.prenom}'),
                const SizedBox(height: 10),
                Text(
                  'Dernier mois payé: ${DateFormat('MMMM', 'fr_FR').format(_selectedPersonne!.moisPaye ?? DateTime.now())}',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _modifierMoisPaye(context);
                  },
                  child: const Text('Modifier le mois payé'),
                ),
              ] else if (_selectedNumero != null) ...[
                const Text('Aucune information pour ce numéro.'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}