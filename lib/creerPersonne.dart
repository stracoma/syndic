// creerPersonne.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';
import 'mois_picker.dart';
import 'comptabilite_service.dart';

class CreerPersonne extends StatefulWidget {
  final Personne? personne;
  const CreerPersonne({super.key, this.personne});

  @override
  _CreerPersonneState createState() => _CreerPersonneState();
}

class _CreerPersonneState extends State<CreerPersonne> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final numeroController = TextEditingController(); // CORRECTION ICI
  DateTime? _moisPaye;
  DateTime? _dateSuscription;
  bool _canEditSubscriptionDate = false; // Utilisé pour gérer l'édition de la date d'inscription

  @override
  void initState() {
    super.initState();
    if (widget.personne != null) {
      nomController.text = widget.personne!.nom;
      prenomController.text = widget.personne!.prenom;
      numeroController.text = widget.personne!.numero.toString();
      _moisPaye = widget.personne!.moisPaye;
      _dateSuscription = widget.personne!.dateSuscription;
      // Si on modifie une personne, on permet l'édition de la date d'inscription
      _canEditSubscriptionDate = true;
    } else {
      // Si on crée une nouvelle personne, la date d'inscription est celle d'aujourd'hui par défaut
      _dateSuscription = DateTime.now();
      _canEditSubscriptionDate = true; // Permettre l'édition pour une nouvelle personne
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => MoisPickerDialog(
        selectedDate: _moisPaye,
        subscriptionDate: _dateSuscription,
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _moisPaye = selectedDate;
      });
    }
  }

  Future<void> _selectSubscriptionDate(BuildContext context) async {
    if (!_canEditSubscriptionDate && widget.personne != null) {
      // Si on modifie une personne et qu'il n'y a pas de permission d'édition
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date d\'inscription ne peut être modifiée qu\'à la création.')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateSuscription ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Pas très loin dans le futur
      locale: const Locale('fr', 'FR'), // Localisation du date picker
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!, // Couleur de la sélection
              onPrimary: Colors.white,
              surface: Colors.blue[50]!, // Couleur du fond du calendrier
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[800], // Couleur du texte des boutons
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateSuscription) {
      setState(() {
        _dateSuscription = picked;
      });
    }
  }

  Future<void> _sauvegarder() async {
    if (_formKey.currentState!.validate()) {
      final nouvellePersonne = Personne(
        id: widget.personne?.id,
        nom: nomController.text,
        prenom: prenomController.text,
        numero: int.parse(numeroController.text),
        moisPaye: _moisPaye,
        dateSuscription: _dateSuscription,
      );

      try {
        if (widget.personne == null) {
          await FirebaseFirestore.instance.collection('personnes').add(nouvellePersonne.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personne ajoutée avec succès !')),
          );
        } else {
          await FirebaseFirestore.instance.collection('personnes').doc(nouvellePersonne.id).update(nouvellePersonne.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personne modifiée avec succès !')),
          );
        }
        // Mettre à jour les totaux après modification/ajout d'une personne
        await ComptabiliteService.updateCotisations();
        await ComptabiliteService.updateSolde();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonthPaid = _moisPaye != null ? DateFormat.yMMMM('fr_FR').format(_moisPaye!) : 'Sélectionner le mois';
    String formattedSubscriptionDate = _dateSuscription != null ? DateFormat('dd/MM/yyyy').format(_dateSuscription!) : 'Sélectionner la date';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personne == null ? 'Ajouter une personne' : 'Modifier une personne'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView( // Pour gérer le défilement si le clavier apparaît
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les enfants horizontalement
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(), // Style de bordure
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding interne
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16), // Espacement
              TextFormField(
                controller: prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: numeroController,
                decoration: const InputDecoration(
                  labelText: 'Numéro',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un numéro';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), // Espacement un peu plus grand avant les dates

              // Date d'inscription
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date d'inscription :",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15, // Taille de police légèrement réduite
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 20), // Icône ajustée
                      label: Text(
                        formattedSubscriptionDate,
                        style: const TextStyle(fontSize: 15), // Taille de texte ajustée
                      ),
                      onPressed: _canEditSubscriptionDate ? () => _selectSubscriptionDate(context) : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Padding ajusté
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()), // Garde un peu d'espace
                ],
              ),
              const SizedBox(height: 16), // Espacement

              // Dernier mois payé
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Dernier mois payé :",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 20),
                      label: Text(
                        formattedMonthPaid,
                        style: const TextStyle(fontSize: 15),
                      ),
                      onPressed: () => _selectMonth(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox()),
                ],
              ),
              const SizedBox(height: 30), // Espacement avant le bouton d'enregistrement
              ElevatedButton(
                onPressed: _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600], // Couleur du bouton
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55), // Bouton plus grand et prend toute la largeur
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Texte plus grand
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Bords arrondis
                ),
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}