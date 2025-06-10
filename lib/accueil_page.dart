// accueil_page.dart
// (Le reste de vos imports et la classe AccueilPage restent inchangés)

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'lesFonctions.dart';
import 'comptabilite_page.dart';
import 'gardiens_page.dart'; // NOUVEAU: Importez la nouvelle page des gardiens

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final String adminPassword = "taiba25";
  final String guestPassword = "techno25";

  bool _buttonsEnabled = false;
  bool _isAdmin = false;

  void _login(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mot de passe'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Entrez le mot de passe'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final entered = passwordController.text.trim();

              if (entered == adminPassword) {
                connexionAdminFirebase(
                  context: context,
                  email: "admin@gmail.com",
                  motDePasse: adminPassword,
                  onSuccess: () {
                    setState(() {
                      _buttonsEnabled = true;
                      _isAdmin = true;
                    });
                    Navigator.pop(context);
                  },
                );
              } else if (entered == guestPassword) {
                connexionAdminFirebase(
                  context: context,
                  email: "invite@gmail.com",
                  motDePasse: guestPassword,
                  onSuccess: () {
                    setState(() {
                      _buttonsEnabled = true;
                      _isAdmin = false;
                    });
                    Navigator.pop(context);
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mot de passe incorrect')),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  // NOTE : La fonction _buildButton() doit être définie ici dans la classe _AccueilPageState
  Widget _buildButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50), // Largeur et hauteur minimales
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Jnane technopolis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 50),
            _buildButton('Se connecter', () => _login(context)),
            const SizedBox(height: 30),
            _buildButton(
              'Cotisations',
              _buttonsEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyHomePage(isAdmin: _isAdmin),
                  ),
                );
              }
                  : null,
            ),
            const SizedBox(height: 30),
            _buildButton(
              'Comptabilité',
              _buttonsEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComptabilitePage()),
                );
              }
                  : null,
            ),
            const SizedBox(height: 30), // AJOUT NOUVEAU ESPACEMENT
            _buildButton( // NOUVEAU BOUTON "Gardiens"
              'Gardiens',
              _buttonsEnabled // Assurez-vous que les boutons sont activés
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GardiensPage()), // Navigue vers la nouvelle page
                );
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}