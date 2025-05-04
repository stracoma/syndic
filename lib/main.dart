import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
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

class Personne {
  String nom;
  String prenom;
  int numero;
  DateTime? moisPaye;

  Personne({
    required this.nom,
    required this.prenom,
    required this.numero,
    this.moisPaye,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Définition des données des personnes
  final List<Personne> _personnes = [
    Personne(nom: "Slaoui1", prenom: "Kamal", numero: 1, moisPaye: DateTime(2024, 1)),
    Personne(nom: "Malki1", prenom: "Brahim", numero: 2, moisPaye: DateTime(2024, 2)),
    Personne(nom: "Slaoui2", prenom: "Kamal", numero: 3, moisPaye: DateTime(2024, 3)),
    Personne(nom: "Malki2", prenom: "Brahim", numero: 4, moisPaye: DateTime(2024, 4)),
    Personne(nom: "Slaoui3", prenom: "Kamal", numero: 5, moisPaye: DateTime(2024, 5)),
    Personne(nom: "Malki3", prenom: "Brahim", numero: 6, moisPaye: DateTime(2024, 6)),
    Personne(nom: "Slaoui4", prenom: "Kamal", numero: 7, moisPaye: DateTime(2024, 7)),
    Personne(nom: "Malki4", prenom: "Brahim", numero: 8, moisPaye: DateTime(2024, 8)),
    Personne(nom: "Slaoui5", prenom: "Kamal", numero: 9, moisPaye: DateTime(2024, 9)),
    Personne(nom: "Malki5", prenom: "Brahim", numero: 10, moisPaye: DateTime(2024, 10)),
    Personne(nom: "Slaoui6", prenom: "Kamal", numero: 11, moisPaye: DateTime(2024, 11)),
    Personne(nom: "Malki7", prenom: "Brahim", numero: 12, moisPaye: DateTime(2024, 12)),
    Personne(nom: "Slaoui7", prenom: "Kamal", numero: 13, moisPaye: DateTime(2025, 1)),
    Personne(nom: "Malki8", prenom: "Brahim", numero: 14, moisPaye: DateTime(2025, 2)),
    Personne(nom: "Slaoui8", prenom: "Kamal", numero: 15, moisPaye: DateTime(2025, 3)),
    Personne(nom: "Malki9", prenom: "Brahim", numero: 16, moisPaye: DateTime(2025, 4)),
    Personne(nom: "Slaoui10", prenom: "Kamal", numero: 17, moisPaye: DateTime(2025, 5)),
    Personne(nom: "Malki10", prenom: "Brahim", numero: 18, moisPaye: DateTime(2025, 6)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 19, moisPaye: DateTime(2025, 7)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 20, moisPaye: DateTime(2025, 8)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 21, moisPaye: DateTime(2025, 9)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 22, moisPaye: DateTime(2025, 10)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 23, moisPaye: DateTime(2025, 11)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 24, moisPaye: DateTime(2025, 12)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 25, moisPaye: DateTime(2026, 1)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 26, moisPaye: DateTime(2026, 2)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 27, moisPaye: DateTime(2026, 3)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 28, moisPaye: DateTime(2026, 4)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 29, moisPaye: DateTime(2026, 5)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 30, moisPaye: DateTime(2026, 6)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 31, moisPaye: DateTime(2026, 7)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 32, moisPaye: DateTime(2026, 8)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 33, moisPaye: DateTime(2026, 9)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 34, moisPaye: DateTime(2026, 10)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 35, moisPaye: DateTime(2026, 11)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 36, moisPaye: DateTime(2026, 12)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 37, moisPaye: DateTime(2027, 1)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 38, moisPaye: DateTime(2027, 2)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 39, moisPaye: DateTime(2027, 3)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 40, moisPaye: DateTime(2027, 4)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 41, moisPaye: DateTime(2027, 5)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 42, moisPaye: DateTime(2027, 6)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 43, moisPaye: DateTime(2027, 7)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 44, moisPaye: DateTime(2027, 8)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 45, moisPaye: DateTime(2027, 9)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 46, moisPaye: DateTime(2027, 10)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 47, moisPaye: DateTime(2027, 11)),
    Personne(nom: "Malki", prenom: "Brahim", numero: 48, moisPaye: DateTime(2027, 12)),
    Personne(nom: "Slaoui", prenom: "Kamal", numero: 49, moisPaye: DateTime(2028, 1)),
  ];

  final TextEditingController _passwordController = TextEditingController();
  final String _adminPassword = "admin"; // Remplacez ceci par votre mot de passe réel
  int? _selectedNumero;
  Personne? _selectedPersonne;
  List<int> _numeros = List.generate(49, (index) => index + 1);

  Personne? _getPersonne(int numero) {
    try {
      return _personnes.firstWhere((personne) => personne.numero == numero);
    } catch (e) {
      return null;
    }
  }

  void _afficherPersonne() {
    if (_selectedNumero != null) {
      Personne? personne = _getPersonne(_selectedNumero!);
      setState(() {
        _selectedPersonne = personne;
      });
    }
  }

  Future<void> _modifierMoisPaye(BuildContext context) async {
    if (_selectedPersonne == null) return;

    // Afficher la boîte de dialogue pour le mot de passe
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
                Navigator.of(context).pop(false); // Retourne false si annulé
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _adminPassword) {
                  Navigator.of(context).pop(true); // Retourne true si correct
                } else {
                  // Afficher un message d'erreur (facultatif)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mot de passe incorrect."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                _passwordController.clear(); // Efface le mot de passe après vérification
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );

    if (isPasswordValid == true) {
      // Si le mot de passe est correct, afficher le DatePicker
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedPersonne!.moisPaye ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('fr', 'FR'),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedPersonne!.moisPaye = pickedDate;
          // Mettre à jour la personne dans la liste _personnes
          int index = _personnes.indexWhere((p) => p.numero == _selectedPersonne!.numero);
          if (index != -1) {
            _personnes[index] = Personne(
              nom: _selectedPersonne!.nom,
              prenom: _selectedPersonne!.prenom,
              numero: _selectedPersonne!.numero,
              moisPaye: pickedDate,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose(); // Important : libérer les ressources du contrôleur
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
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Sélectionner un numéro',
                  border: OutlineInputBorder(),
                ),
                value: _selectedNumero,
                items: _numeros.map((numero) {
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
                  'Dernier mois payé: ${DateFormat('MMMM yyyy', 'fr_FR').format(_selectedPersonne!.moisPaye ?? DateTime.now())}',
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

