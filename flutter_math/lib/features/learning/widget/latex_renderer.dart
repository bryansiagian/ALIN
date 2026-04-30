import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexRenderer extends StatelessWidget {
  final String latex;
  final double fontSize;
  final Color? color;

  const LatexRenderer({
    super.key, 
    required this.latex, 
    this.fontSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Math.tex(
        latex,
        // Ganti 'style' menjadi 'textStyle' agar dikenali oleh flutter_math_fork
        textStyle: TextStyle(
          fontSize: fontSize,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        onErrorFallback: (err) => Text(
          "Error render rumus: $latex",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}