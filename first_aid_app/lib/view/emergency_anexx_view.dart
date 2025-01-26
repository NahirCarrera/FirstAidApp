import 'package:flutter/material.dart';
import '../controller/emergency_controller.dart';
import '../model/step_model.dart' as model;

class EmergencyAnnexView extends StatelessWidget {
  final String annexId;

  EmergencyAnnexView({required this.annexId});

  @override
  Widget build(BuildContext context) {
    final EmergencyController _controller = EmergencyController();
    List<model.Step>? annexSteps = _controller.getStepsForEmergency(annexId);

    bool isProcessEnded = annexSteps?.any((step) => step.id == "X" || step.id == "NULL") ?? false;

    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Annex $annexId Steps',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: annexSteps!.map((step) {
                // Puedes cambiar el ícono dependiendo del tipo de paso
                IconData icon = Icons.check_circle; // Por defecto, ícono de check
                if (step.number == "1") {
                  icon = Icons.info; // Ejemplo, el primer paso tiene un ícono diferente
                }

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: Colors.blue[800], size: 24),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${step.number}:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              step.instruction ?? '',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (isProcessEnded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'The process for this annex has ended.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el modal
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
