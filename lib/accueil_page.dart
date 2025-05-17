import 'package:flutter/material.dart';
import 'home_page.dart';
import 'lesFonctions.dart';

class AccueilPage extends StatelessWidget {
  final String adminPassword = "taiba25";
  final String guestPassword = "techno25";

  const AccueilPage({super.key});

  void _login(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mot de passe'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Entrez le mot de passe'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final entered = passwordController.text.trim();

              if (entered == adminPassword) {
                // Connexion admin Firebase
                connexionAdminFirebase(
                  context: context,
                  email: "admin@gmail.com",
                  motDePasse: adminPassword,
                  onSuccess: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyHomePage(isAdmin: true)),
                    );
                  },
                );
              } else if (entered == guestPassword) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyHomePage(isAdmin: false)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[500],
      appBar: AppBar(
          backgroundColor: Colors.amber[800],
          title: Text('Jnane technopolis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
    )),
      body: Center(

        child: ElevatedButton.icon(
          icon: Icon(Icons.lock),
          label: Text('Se connecter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800], // Couleur de fond
          ),

          onPressed: () => _login(context),
        ),
      ),
    );
  }
}
