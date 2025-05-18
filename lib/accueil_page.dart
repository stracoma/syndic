import 'package:flutter/material.dart';
import 'home_page.dart';
import 'lesFonctions.dart';

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
                setState(() {
                  _buttonsEnabled = true;
                  _isAdmin = false;
                });
                Navigator.pop(context);
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

  Widget _buildButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[800],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[500],
      appBar: AppBar(
        backgroundColor: Colors.amber[800],
        title: Text(
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
            _buildButton('Se connecter', () => _login(context)),
            SizedBox(height: 30),
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
            SizedBox(height: 20),
            _buildButton(
              'Comptabilité',
              _buttonsEnabled ? () {} : null,
            ),
          ],
        ),
      ),
    );
  }
}
