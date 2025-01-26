import 'package:flutter/material.dart';
import '../controller/emergency_controller.dart';
import 'emergency_step_view.dart';
import '../utils/colors.dart'; // Asegúrate de importar el archivo de los colores

class EmergencyListView extends StatefulWidget {
  @override
  _EmergencyListViewState createState() => _EmergencyListViewState();
}

class _EmergencyListViewState extends State<EmergencyListView> {
  final EmergencyController _controller = EmergencyController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadEmergencies();
    await _controller.loadSteps();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergencies'),
        backgroundColor: AppColors.primaryColor, // Azul calmante para la app bar
      ),
      body: _controller.emergencies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos columnas en la cuadrícula
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0, // Ajustar el tamaño de los elementos
        ),
        itemCount: _controller.emergencies.length,
        itemBuilder: (context, index) {
          final emergency = _controller.emergencies[index];
          return Card(
            color: AppColors.neutralGray, // Color de fondo para cada tarjeta
            elevation: 4.0, // Sombra para darle profundidad
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StepView(emergencyId: emergency.id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning, // Icono para representar emergencias
                      size: 40.0,
                      color: AppColors.primaryColor, // Icono en azul calmante
                    ),
                    SizedBox(height: 10),
                    Text(
                      emergency.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor, // Color del texto
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
