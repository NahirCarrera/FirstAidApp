class Emergency {
  final String id;
  final String name;
  final String description;
  final String ageGroup;
  final String severity;
  final String tag;
  final String initialEvaluation;

  Emergency({
    required this.id,
    required this.name,
    required this.description,
    required this.ageGroup,
    required this.severity,
    required this.tag,
    required this.initialEvaluation,
  });

  factory Emergency.fromJson(Map<String, dynamic> json) {
    return Emergency(
      id: json['id_emergencia']??'',
      name: json['emergencia']??'',
      description: json['descripcion']??'',
      ageGroup: json['grupo_edad']??'',
      severity: json['severidad']??'',
      tag: json['etiqueta']??'',
      initialEvaluation: json['evaluacion_inicial']??'',
    );
  }
}
