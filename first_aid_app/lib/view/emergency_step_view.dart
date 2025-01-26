import 'package:flutter/material.dart';
import '../controller/emergency_controller.dart';
import '../model/step_model.dart' as model;
import 'emergency_anexx_view.dart';

class StepView extends StatefulWidget {
  final String emergencyId;

  StepView({required this.emergencyId});

  @override
  _StepViewState createState() => _StepViewState();
}

class _StepViewState extends State<StepView> {
  final EmergencyController _controller = EmergencyController();
  List<model.Step>? _stepsForEmergency;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.loadSteps().then((_) {
      _stepsForEmergency = _controller.getStepsForEmergency(widget.emergencyId);
      setState(() {});
    });
  }

  void _navigateToStep(int index) {
    setState(() {
      _currentStepIndex = index;
    });
  }

  void _showConditionDialog(List<String> nextStepIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Condition'),
        content: Text(_stepsForEmergency?[_currentStepIndex].instruction ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Si el usuario selecciona "Sí", va al siguiente paso 1
              if (nextStepIds.isNotEmpty) {
                String nextStepId = nextStepIds[0]; // Paso siguiente 1
                var nextStep = _stepsForEmergency?.firstWhere(
                        (step) => step.id == nextStepId);
                if (nextStep != null) {
                  _navigateToStep(_stepsForEmergency!.indexOf(nextStep));
                }
              }
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Si el usuario selecciona "No", va al siguiente paso 2
              if (nextStepIds.length > 1) {
                String nextStepId = nextStepIds[1]; // Paso siguiente 2
                var nextStep = _stepsForEmergency?.firstWhere(
                        (step) => step.id == nextStepId);
                if (nextStep != null) {
                  _navigateToStep(_stepsForEmergency!.indexOf(nextStep));
                }
              }
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  void _showAnnexDialog(String annexId) {
    // Obtener los pasos relacionados al anexo
    List<model.Step>? annexSteps = _controller.getStepsForEmergency(annexId);

    // Verificar si annexSteps es nulo o vacío
    if (annexSteps == null || annexSteps.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Annex Steps Available'),
          content: Text('No steps are available for this annex.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        ),
      );
      return; // Salir de la función si no hay pasos
    }

    // Verificar si todos los pasos están marcados como "X" o son nulos
    bool isProcessEnded = annexSteps.any((step) => step.id == "X" || step.id == "NULL");

    // Mostrar los pasos del anexo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annex $annexId Steps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: annexSteps.map((step) {
            // Mostrar cada paso
            return Text('Step ${step.number}: ${step.instruction}');
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isProcessEnded) {
                // Si el proceso ha terminado, mostrar un mensaje final
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Process Completed'),
                    content: Text('The process for this annex has ended.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stepsForEmergency == null || _stepsForEmergency!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Steps')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentStep = _stepsForEmergency![_currentStepIndex];
    final isCondition = currentStep.id.startsWith('C');
    final hasAnnexes = currentStep.annexes != null && currentStep.annexes!.isNotEmpty;
    final nextSteps = currentStep.nextSteps;

    // Verificar si el siguiente paso es 'NULL' o 'X'
    bool isNextStepValid = nextSteps.isNotEmpty &&
        !(nextSteps[0] == 'NULL' || nextSteps[0] == 'X');

    return Scaffold(
      appBar: AppBar(
        title: Text('Steps'),
        backgroundColor: Colors.green, // Color personalizado de la app
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Paso centrado en la pantalla
              Text(
                'Step ${currentStep.number}: ${currentStep.instruction}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              // Cuadro rojo de advertencia para la observación
              if (currentStep.observation.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  color: Colors.red[100],
                  child: Text(
                    'Observation: ${currentStep.observation}',
                    style: TextStyle(fontSize: 16, color: Colors.red[800]),
                  ),
                ),

              // Mostrar anexos si existen
              if (hasAnnexes)
                Column(
                  children: currentStep.annexes!.map((annexId) {
                    return ElevatedButton(
                      onPressed: () => _showAnnexDialog(annexId),
                      child: Text('View Annex $annexId'),
                    );
                  }).toList(),
                ),
              Spacer(),
              // Botón para condiciones
              if (isCondition)
                ElevatedButton(
                  onPressed: () => _showConditionDialog(nextSteps),
                  child: Text('Answer Condition'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                )
              // Mostrar siguiente paso si existe y el siguiente paso es válido
              else if (isNextStepValid)
                ElevatedButton(
                  onPressed: () => _navigateToStep(_currentStepIndex + 1),
                  child: Text('Next Step'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                )
              // Si el siguiente paso no es válido, mostrar un mensaje
              else
                Text('The next step is not available or completed.'),
            ],
          ),
        ),
      ),
    );
  }
}
