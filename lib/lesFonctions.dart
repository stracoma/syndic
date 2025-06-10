// lesFonctions.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'creerPersonne.dart';
import 'personne.dart';

Future<void> afficherDialogueMotDePasse({
  required BuildContext context,
  required String motDePasseAdmin,
  required Function() onSuccess,
}) async {
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mot de passe administrateur'),
      content: SingleChildScrollView( // Permet le défilement si le clavier apparaît
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
            border: OutlineInputBorder(), // Style de bordure
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton( // Changement de TextButton à ElevatedButton
          onPressed: () {
            if (controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              onSuccess();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: const Text('Valider'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700], // Couleur du bouton
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Future<void> connexionAdminFirebase({
  required BuildContext context,
  required String email,
  required String motDePasse,
  required VoidCallback onSuccess,
}) async {
  try {
    // Tentative de connexion avec Firebase Auth
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: motDePasse,
    );
    onSuccess();
  } on FirebaseAuthException catch (e) {
    String message;
    if (e.code == 'user-not-found') {
      message = 'Aucun utilisateur trouvé pour cet email.';
    } else if (e.code == 'wrong-password') {
      message = 'Mot de passe incorrect.';
    } else {
      message = 'Erreur de connexion: ${e.message}';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Une erreur inattendue est survenue: $e')),
    );
  }
}

void afficherDialoguePourEdition({
  required BuildContext context,
  required String motDePasseAdmin,
  required Personne personne,
}) {
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmer l\'édition'),
      content: SingleChildScrollView( // Permet le défilement
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe administrateur',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreerPersonne(personne: personne),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: const Text('Valider'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}

void afficherDialoguePourCreation({
  required BuildContext context,
  required String motDePasseAdmin,
}) {
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mot de passe requis'),
      content: SingleChildScrollView( // Permet le défilement
        child: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreerPersonne()), // `const` si pas de paramètre
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: const Text('Valider'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}