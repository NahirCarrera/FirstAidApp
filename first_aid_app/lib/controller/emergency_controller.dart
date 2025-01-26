import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/emergency_model.dart';
import '../model/step_model.dart';

class EmergencyController {
  List<Emergency> emergencies = [];
  Map<String, List<Step>> stepsByEmergency = {};
  Map<String, Step> stepsById = {}; // Mapa de pasos por ID

  Future<void> loadEmergencies() async {
    try {
      final data = await rootBundle.loadString('assets/emergencies.json');
      final List<dynamic> jsonList = jsonDecode(data);
      emergencies = jsonList.map((json) => Emergency.fromJson(json)).toList();
    } catch (e) {
      print('Error loading emergencies: $e');
    }
  }

  Future<void> loadSteps() async {
    try {
      final data = await rootBundle.loadString('assets/steps.json');
      final List<dynamic> jsonList = jsonDecode(data);
      for (var json in jsonList) {
        final step = Step.fromJson(json);

        // Guardamos el paso por ID para acceso rápido
        stepsById[step.id] = step;

        // Si el paso tiene más de un paso siguiente, los agregamos por separado
        if (step.nextSteps.isNotEmpty) {
          for (var nextStepId in step.nextSteps) {
            final nextStep = getStepById(nextStepId);
            if (nextStep != null) {
              _addStepToEmergency(nextStep);
            }
          }
        }

        // Si el paso tiene más de un anexo, los agregamos por separado
        if (step.annexes?.isNotEmpty ?? false) {
          for (var annexId in step.annexes!) {
            final annexSteps = getStepsForAnnex(annexId);
            if (annexSteps != null) {
              for (var annexStep in annexSteps) {
                _addStepToEmergency(annexStep);
              }
            }
          }
        }

        // Finalmente, agregamos el paso principal al mapa de pasos
        _addStepToEmergency(step);
      }

      print('Pasos cargados: ${stepsByEmergency}');
    } catch (e) {
      print('Error loading steps: $e');
    }
  }

  // Método para agregar un paso a stepsByEmergency si no está ya presente
  void _addStepToEmergency(Step step) {
    if (!stepsByEmergency.containsKey(step.emergencyId)) {
      stepsByEmergency[step.emergencyId] = [];
    }

    // Verificamos si el paso ya está presente antes de agregarlo
    if (!stepsByEmergency[step.emergencyId]!.any((s) => s.id == step.id)) {
      stepsByEmergency[step.emergencyId]!.add(step);
    }
  }

  List<Step>? getStepsForEmergency(String emergencyId) {
    final steps = stepsByEmergency[emergencyId];
    if (steps != null && steps.isNotEmpty) {
      print('Pasos encontrados para la emergencia $emergencyId:');
      for (var step in steps) {
        print('Paso ID: ${step.id}, Instrucción: ${step.instruction}');
      }
    } else {
      print('No se encontraron pasos para la emergencia $emergencyId');
    }
    return steps;
  }

  Emergency? getEmergencyById(String id) {
    return emergencies.firstWhere((e) => e.id == id, orElse: () =>  throw Exception('Emergency not found'));
  }

  Step? getStepById(String stepId) {
    return stepsById[stepId];
  }

  List<Step>? getStepsForAnnex(String annexId) {
    final annexSteps = stepsByEmergency.values
        .expand((e) => e)
        .where((step) => step.id == annexId)
        .toList();

    if (annexSteps.isNotEmpty) {
      print('Pasos encontrados para el anexo $annexId:');
      for (var step in annexSteps) {
        print('Paso ID: ${step.id}, Instrucción: ${step.instruction}');
      }
    } else {
      print('No se encontraron pasos para el anexo $annexId');
    }

    return annexSteps.isNotEmpty ? annexSteps : null;
  }
}
