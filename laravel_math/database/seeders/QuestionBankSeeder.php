<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\QuestionBank;

class QuestionBankSeeder extends Seeder
{
    public function run()
    {
        // PERHATIAN: Pastikan Anda memiliki Topic dengan ID 1 di database Anda (Topik: Matriks Dasar)
        $topicId = 1;

        // Mesin pencetak berjalan 100 kali
        for ($i = 1; $i <= 100; $i++) {

            // 1. Cetak 1 Soal EASY
            QuestionBank::create([
                'topic_id'       => $topicId,
                'question_text'  => "Soal Uji Coba MUDAH nomor $i. Berapakah 1 + 1?",
                'question_type'  => 'multiple_choice',
                'difficulty'     => 'easy',
                'options'        => [
                    ["label" => "A", "text" => "1"],
                    ["label" => "B", "text" => "2"],
                    ["label" => "C", "text" => "3"],
                    ["label" => "D", "text" => "4"]
                ],
                'correct_answer' => 'B',
                'explanation'    => "Penjelasan untuk soal mudah nomor $i",
            ]);

            // 2. Cetak 1 Soal MEDIUM
            QuestionBank::create([
                'topic_id'       => $topicId,
                'question_text'  => "Soal Uji Coba SEDANG nomor $i. Tentukan nilai x!",
                'question_type'  => 'multiple_choice',
                'difficulty'     => 'medium',
                'options'        => [
                    ["label" => "A", "text" => "5"],
                    ["label" => "B", "text" => "10"],
                    ["label" => "C", "text" => "15"],
                    ["label" => "D", "text" => "20"]
                ],
                'correct_answer' => 'C',
                'explanation'    => "Penjelasan untuk soal sedang nomor $i",
            ]);

            // 3. Cetak 1 Soal HARD
            QuestionBank::create([
                'topic_id'       => $topicId,
                'question_text'  => "Soal Uji Coba SUSAH nomor $i. Hitunglah invers matriks!",
                'question_type'  => 'multiple_choice',
                'difficulty'     => 'hard',
                'options'        => [
                    ["label" => "A", "text" => "Matriks X"],
                    ["label" => "B", "text" => "Matriks Y"],
                    ["label" => "C", "text" => "Matriks Z"],
                    ["label" => "D", "text" => "Tidak Punya Invers"]
                ],
                'correct_answer' => 'D',
                'explanation'    => "Penjelasan untuk soal susah nomor $i",
            ]);
        }
    }
}
