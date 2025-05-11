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
      title: Text('Mot de passe administrateur'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Mot de passe'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              onSuccess();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: Text('Valider'),
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
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: motDePasse,
    );
    onSuccess();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Échec de connexion Firebase')),
    );
  }
}

void afficherDialoguePourEdition({
  required BuildContext context,
  required String motDePasseAdmin,
  required Personne personne,
}) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Mot de passe requis'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Mot de passe'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreerPersonne(personne: personne),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: Text('Valider'),
        ),
      ],
    ),
  );
}

void afficherDialoguePourCreation({
  required BuildContext context,
  required String motDePasseAdmin,
}) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Mot de passe requis'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Mot de passe'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text == motDePasseAdmin) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreerPersonne()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mot de passe incorrect')),
              );
            }
          },
          child: Text('Valider'),
        ),
      ],
    ),
  );
}
