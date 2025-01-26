class Step {
  final String id;
  final String emergencyId;
  final int number;
  final String instruction;
  final String observation;
  final String? image;
  final String? previousStep;
  final List<String> nextSteps;  // Cambiado a una lista
  final List<String>? annexes;   // Cambiado a una lista

  Step({
    required this.id,
    required this.emergencyId,
    required this.number,
    required this.instruction,
    required this.observation,
    this.image,
    this.previousStep,
    required this.nextSteps,  // Ahora es una lista
    this.annexes,  // Ahora es una lista
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['id_paso'],
      emergencyId: json['id_emergencia'],
      number: json['numero'],
      instruction: json['instruccion'],
      observation: json['observacion'],
      image: json['imagen'],
      previousStep: json['paso anterior'] == 'NULL' ? null : json['paso anterior'],
      // Separar pasos siguientes y anexos por salto de línea
      nextSteps: (json['paso siguiente'] is String
          ? (json['paso siguiente'] as String).split('\n')
          : []),
      annexes: json['anexo'] != null && json['anexo'].isNotEmpty
          ? (json['anexo'] as String).split('\n')  // Separar los anexos por salto de línea
          : null,
    );
  }
}
