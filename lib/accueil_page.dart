import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'lesFonctions.dart';

class AccueilPage extends StatelessWidget {
  final String adminPassword = "admin";

  void _adminLogin(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mot de passe administrateur'),
        content: TextField(
          controller: passwordController,
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
              if (passwordController.text == adminPassword) {
                connexionAdminFirebase(
                  context: context,
                  email: "mohamed@gmail.com",
                  motDePasse: "Taiba2025",
                  onSuccess: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyHomePage(isAdmin: true)),
                    );
                  },
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

  void _invitedAccess(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyHomePage(isAdmin: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page d\'accueil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.lock),
              label: Text('Administrateur'),
              onPressed: () => _adminLogin(context),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.visibility),
              label: Text('Invité'),
              onPressed: () => _invitedAccess(context),
            ),
          ],
        ),
      ),
    );
  }
}
