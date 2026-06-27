<?php

namespace App\Imports;

use App\Models\QuestionBank; // <--- UBAH: Gunakan model QuestionBank, bukan PlacementQuestion
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;

class PlacementImport implements ToModel, WithHeadingRow
{
    public function model(array $row)
    {
        // --- PENYARING SAMPAH ---
        if (!isset($row['question_text']) || empty(trim($row['question_text']))) {
            return null;
        }

        // Simpan langsung ke laci QuestionBank dengan label khusus
        return new QuestionBank([
            'topic_id'       => 1, // Set default ke topic_id 1 (atau sesuaikan dengan database Anda)
            'question_text'  => $row['question_text'],
            'options'        => [
                'A' => $row['option_a'] ?? '',
                'B' => $row['option_b'] ?? '',
                'C' => $row['option_c'] ?? '',
                'D' => $row['option_d'] ?? ''
            ], // Biarkan berupa array, mutator casting model yang akan mengubahnya menjadi JSON
            'correct_answer' => strtoupper($row['correct_answer'] ?? 'A'),
            'difficulty'     => $row['difficulty'] ?? 'medium',
            'is_quiz'        => false,
            'is_placement'   => true, // <--- INI KUNCI UTAMANYA! Ditandai sebagai soal penempatan
        ]);
    }
}
