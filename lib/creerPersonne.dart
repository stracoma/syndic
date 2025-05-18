import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personne.dart';
import 'mois_picker.dart';


class CreerPersonne extends StatefulWidget {
  final Personne? personne;

  const CreerPersonne({Key? key, this.personne}) : super(key: key);

  @override
  _CreerPersonneState createState() => _CreerPersonneState();
}

class _CreerPersonneState extends State<CreerPersonne> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final numeroController = TextEditingController();
  DateTime? _moisPaye;

  @override
  void initState() {
    super.initState();
    if (widget.personne != null) {
      nomController.text = widget.personne!.nom;
      prenomController.text = widget.personne!.prenom;
      numeroController.text = widget.personne!.numero.toString();
      _moisPaye = widget.personne!.moisPaye;
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) => MoisPickerDialog(selectedDate: _moisPaye),
    );

    if (selectedDate != null) {
      setState(() {
        _moisPaye = selectedDate;
      });
    }
  }

  void _sauvegarder() async {
    if (_formKey.currentState!.validate()) {
      final nom = nomController.text.trim();
      final prenom = prenomController.text.trim();
      final numero = int.parse(numeroController.text.trim());

      final personne = Personne(
        nom: nom,
        prenom: prenom,
        numero: numero,
        moisPaye: _moisPaye,
      );

      final collection = FirebaseFirestore.instance.collection('personnes');

      if (widget.personne == null) {
        await collection.add(personne.toMap());
      } else {
        await collection.doc(widget.personne!.id).update(personne.toMap());
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _moisPaye != null
        ? DateFormat.yMMMM('fr_FR').format(_moisPaye!)
        : 'Choisir mois';

    return Scaffold(
      appBar: AppBar(title: const Text("Créer / Modifier Personne")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Numéro'),
                validator: (value) =>
                value!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(formattedDate),
                onPressed: () => _selectMonth(context),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _sauvegarder,
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
