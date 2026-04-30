class FormulaModel {
  final int id;
  final String title;
  final String latexExpression;
  final String? description;

  FormulaModel({required this.id, required this.title, required this.latexExpression, this.description});

  factory FormulaModel.fromJson(Map<String, dynamic> json) => FormulaModel(
    id: json['id'],
    title: json['title'],
    latexExpression: json['latex_expression'],
    description: json['description'],
  );
}