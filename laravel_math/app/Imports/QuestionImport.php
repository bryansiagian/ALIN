<?php

namespace App\Imports;

use App\Models\QuestionBank;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings; // KUNCI MUTLAK PEMBACA CSV
use Illuminate\Support\Facades\Log; // KUNCI MUTLAK DEBUGGING

class QuestionImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    // Memaksa Laravel membaca file menggunakan KOMA, bukan titik koma
    public function getCsvSettings(): array
    {
        return [
            'delimiter' => ','
        ];
    }

    public function model(array $row)
    {

        //dd($row);
        // --- SISTEM DEBUGGING ---
        // Perintah ini akan mencetak apa yang sebenarnya dilihat oleh Laravel
        // ke dalam file log Anda.
        Log::info('Membaca Baris: ', $row);

        // 1. Lewati baris jika teks soalnya kosong (atau kunci tidak ditemukan)
        if (!isset($row['question_text']) || empty($row['question_text'])) {
            Log::warning('Baris dilewati karena question_text kosong/tidak terdeteksi.');
            return null;
        }

        // 2. Gabungkan pilihan ganda
        $options = [];
        if (!empty($row['option_a'])) $options[] = ['label' => 'A', 'text' => (string)$row['option_a']];
        if (!empty($row['option_b'])) $options[] = ['label' => 'B', 'text' => (string)$row['option_b']];
        if (!empty($row['option_c'])) $options[] = ['label' => 'C', 'text' => (string)$row['option_c']];
        if (!empty($row['option_d'])) $options[] = ['label' => 'D', 'text' => (string)$row['option_d']];
        if (!empty($row['option_e'])) $options[] = ['label' => 'E', 'text' => (string)$row['option_e']];

        // 3. Filter Kunci Jawaban
        $rawAnswer = strtoupper($row['correct_answer'] ?? 'A');
        $cleanAnswer = preg_replace('/[^A-E]/', '', $rawAnswer);
        $finalAnswer = substr($cleanAnswer, 0, 1);
        if (empty($finalAnswer)) {
            $finalAnswer = 'A';
        }

        // 4. Masukkan ke Database
        return new QuestionBank([
            'topic_id'       => $row['topic_id'] ?? 1,
            'question_text'  => $row['question_text'],
            'question_type'  => $row['question_type'] ?? 'multiple_choice',
            'difficulty'     => $row['difficulty'] ?? 'medium',
            'options'        => $options,
            'correct_answer' => $finalAnswer,
            'explanation'    => $row['explanation'] ?? null,
        ]);
    }
}
