import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/widget/latex_renderer.dart';

class FormulaSheetScreen extends ConsumerWidget {
  const FormulaSheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formulasAsync = ref.watch(formulasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Referensi Rumus")),
      body: formulasAsync.when(
        data: (formulas) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: formulas.length,
          itemBuilder: (context, index) {
            final formula = formulas[index];
            return Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formula.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    FittedBox(
                      child: LatexRenderer(latex: formula.latexExpression),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}