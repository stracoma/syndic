// mois_picker.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoisPickerDialog extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? subscriptionDate;

  const MoisPickerDialog({
    super.key,
    this.selectedDate,
    this.subscriptionDate,
  });

  @override
  State<MoisPickerDialog> createState() => _MoisPickerDialogState();
}

class _MoisPickerDialogState extends State<MoisPickerDialog> {
  late int selectedYear;
  late int? selectedMonth;
  late DateTime? currentSelectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = widget.selectedDate?.year ?? now.year;
    selectedMonth = widget.selectedDate?.month;
    currentSelectedDate = widget.selectedDate;
  }

  void _changeYear(int delta) {
    setState(() {
      selectedYear += delta;
      // Optionnel: Si vous voulez réinitialiser la sélection de mois quand l'année change
      // currentSelectedDate = null;
    });
  }

  bool _shouldHighlightMonth(int month) {
    if (widget.subscriptionDate == null) {
      return false; // Pas de date d'inscription, pas de surlignage
    }

    final currentMonthFirstDay = DateTime(selectedYear, month, 1);
    final subscriptionMonthFirstDay = DateTime(
        widget.subscriptionDate!.year,
        widget.subscriptionDate!.month,
        1
    );

    // Si une date de sélection actuelle existe, vérifie si le mois est inclus dans la plage
    if (currentSelectedDate != null) {
      final selectedMonthFirstDay = DateTime(
          currentSelectedDate!.year,
          currentSelectedDate!.month,
          1
      );
      // Le mois doit être entre la date d'inscription et la date sélectionnée (inclus)
      return (currentMonthFirstDay.isAtSameMomentAs(subscriptionMonthFirstDay) ||
          currentMonthFirstDay.isAfter(subscriptionMonthFirstDay)) &&
          (currentMonthFirstDay.isAtSameMomentAs(selectedMonthFirstDay) ||
              currentMonthFirstDay.isBefore(selectedMonthFirstDay));
    } else {
      // Si aucune date de sélection actuelle n'est définie, ne surligne que les mois à partir de la date d'inscription
      return currentMonthFirstDay.isAtSameMomentAs(subscriptionMonthFirstDay) ||
          currentMonthFirstDay.isAfter(subscriptionMonthFirstDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, size: 30), // Plus grande icône
                onPressed: () => _changeYear(-1),
                color: Colors.blue[800],
              ),
              Text(
                selectedYear.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right, size: 30), // Plus grande icône
                onPressed: () => _changeYear(1),
                color: Colors.blue[800],
              ),
            ],
          ),
          const SizedBox(height: 10), // Espacement sous l'année
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 20), // Padding du contenu
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55, // 55% de la hauteur de l'écran
        width: double.maxFinite,
        child: GridView.count(
          crossAxisCount: 2, // 2 colonnes, adapté pour les mois
          mainAxisSpacing: 10, // Espacement vertical entre les mois
          crossAxisSpacing: 10, // Espacement horizontal entre les mois
          childAspectRatio: 3, // Ratio largeur/hauteur pour des boutons rectangulaires
          children: List.generate(12, (index) {
            final month = index + 1;
            final monthDate = DateTime(selectedYear, month, 10); // Jour arbitraire pour le mois
            final monthName = DateFormat.MMMM('fr_FR').format(monthDate);
            final isSelected = month == currentSelectedDate?.month &&
                selectedYear == currentSelectedDate?.year;
            final shouldHighlight = _shouldHighlightMonth(month);

            return ElevatedButton(
              onPressed: () {
                setState(() {
                  currentSelectedDate = monthDate;
                });
                Navigator.of(context).pop(monthDate); // Retourne la date complète
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Padding interne du bouton
                minimumSize: const Size(double.infinity, 55), // Hauteur minimale du bouton
                backgroundColor: shouldHighlight ? Colors.green[600] : Colors.blue[700], // Couleur pour surligné vs normal
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold), // Texte plus grand et gras
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bords arrondis
                  side: isSelected
                      ? const BorderSide(color: Colors.amber, width: 3) // Bordure distincte si sélectionné
                      : BorderSide.none,
                ),
              ),
              child: Text(
                monthName,
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ),
    );
  }
}