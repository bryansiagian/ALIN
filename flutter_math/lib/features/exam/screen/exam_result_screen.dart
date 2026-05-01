import 'package:flutter/material.dart';

class ExamResultScreen extends StatelessWidget {
  final int score;
  final List questions;
  final Map<int, String> userAnswers;
  final bool canShowDetail; // Ini patokannya (show_results)

  const ExamResultScreen({
    super.key, 
    required this.score, 
    required this.questions, 
    required this.userAnswers,
    required this.canShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Ujian"), 
        automaticallyImplyLeading: false
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ICON BERHASIL
            const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            
            Text(
              canShowDetail ? "Hasil Ujian Anda" : "Ujian Berhasil Dikirim",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // LOGIKA SEMBUNYIKAN SKOR & DETAIL
            if (canShowDetail) ...[
              // TAMPILKAN SKOR
              const Text("Skor Anda:", style: TextStyle(fontSize: 16)),
              Text(
                "$score", 
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.indigo)
              ),
              const SizedBox(height: 30),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Review Jawaban:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              
              ...questions.map((q) {
                String userAnswer = userAnswers[q['id']] ?? "Tidak dijawab";
                bool isCorrect = userAnswer == q['correct_answer'];
                return Card(
                  color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(q['question_text']),
                    subtitle: Text("Jawaban Anda: $userAnswer\nKunci: ${q['correct_answer']}"),
                    trailing: Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red),
                  ),
                );
              }),
            ] else ...[
              // JIKA SHOW_RESULTS = FALSE, TAMPILKAN PESAN INI SAJA
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Card(
                  elevation: 0,
                  color: Colors.amber.shade100, // Pakai warna soft
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Terima kasih telah mengerjakan ujian. Skor dan detail jawaban Anda telah disimpan di sistem dan disembunyikan oleh dosen pengampu.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text("Kembali ke Beranda"),
            )
          ],
        ),
      ),
    );
  }
}