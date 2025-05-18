import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoisPickerDialog extends StatefulWidget {
  final DateTime? selectedDate;

  MoisPickerDialog({this.selectedDate});

  @override
  _MoisPickerDialogState createState() => _MoisPickerDialogState();
}

class _MoisPickerDialogState extends State<MoisPickerDialog> {
  late int selectedYear;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = widget.selectedDate?.year ?? now.year;
    selectedMonth = widget.selectedDate?.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                selectedYear--;
              });
            },
          ),
          Text(
            '$selectedYear',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                selectedYear++;
              });
            },
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2, // 2 boutons par ligne
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 3,
          children: List.generate(12, (index) {
            final monthDate = DateTime(selectedYear, index + 1, 10);
            final monthName = DateFormat.MMMM('fr_FR').format(monthDate);

            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(monthDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (index + 1 == selectedMonth)
                    ? Colors.blue
                    : Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(monthName, style: TextStyle(fontSize: 16)),
            );
          }),
        ),
      ),
    );
  }
}
