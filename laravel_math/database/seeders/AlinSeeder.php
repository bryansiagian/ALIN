<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Topic;
use App\Models\Material;
use App\Models\Formula;
use App\Models\QuestionBank;
use App\Models\Assignment;
use Illuminate\Support\Facades\Hash;

class AlinSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Buat User Dosen
        $lecturer = User::create([
            'name' => 'Sari Muthia Silalahi',
            'email' => 'dosen@alin.com',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
            'nidn' => '0012345678',
        ]);

        // Buat User Mahasiswa
        User::create([
            'name' => 'Bryan',
            'email' => 'student@alin.com',
            'password' => Hash::make('password123'),
            'role' => 'student',
            'nim' => '42324029',
            'prodi' => 'Teknologi Informasi',
        ]);

        // 2. Buat Topik Matriks
        $topicMatriks = Topic::create([
            'title' => 'Matriks Dasar',
            'slug' => 'matriks-dasar',
            'description' => 'Mempelajari dasar-dasar matriks, operasi, dan determinan.',
            'order_index' => 1,
            'is_active' => true,
        ]);

        // 3. Buat Soal-soal (Simpan ID-nya ke dalam array)
        $qIds = [];

        $q1 = QuestionBank::create([
            'topic_id' => $topicMatriks->id,
            'question_text' => 'Berapakah determinan dari matriks A = [[3, 2], [1, 4]]?',
            'question_type' => 'multiple_choice',
            'difficulty' => 'easy',
            'options' => [
                ['key' => 'A', 'text' => '10'],
                ['key' => 'B', 'text' => '12'],
                ['key' => 'C', 'text' => '14'],
                ['key' => 'D', 'text' => '16']
            ],
            'correct_answer' => 'A',
            'explanation' => 'Determinan = (3 * 4) - (2 * 1) = 12 - 2 = 10.',
        ]);
        $qIds[] = $q1->id;

        $q2 = QuestionBank::create([
            'topic_id' => $topicMatriks->id,
            'question_text' => 'Matriks yang semua elemen diagonalnya adalah 1 disebut...',
            'question_type' => 'multiple_choice',
            'difficulty' => 'easy',
            'options' => [
                ['key' => 'A', 'text' => 'Matriks Nol'],
                ['key' => 'B', 'text' => 'Matriks Identitas'],
                ['key' => 'C', 'text' => 'Matriks Skalar'],
                ['key' => 'D', 'text' => 'Matriks Diagonal']
            ],
            'correct_answer' => 'B',
            'explanation' => 'Matriks Identitas memiliki elemen 1 pada diagonal utama.',
        ]);
        $qIds[] = $q2->id;

        // 4. Buat Penugasan/Quiz
        $quiz = Assignment::create([
            'lecturer_id' => $lecturer->id,
            'topic_id' => $topicMatriks->id,
            'title' => 'Quiz Mingguan: Dasar Matriks',
            'description' => 'Kerjakan quiz ini dengan jujur. Mode SEB Aktif.',
            'deadline' => now()->addDays(7),
            'duration_minutes' => 30,
            'question_count' => 2,
            'is_safe_exam' => true,
            'status' => 'published',
            // Tambahkan default setting lainnya sesuai kriteria kita sebelumnya
            'allow_reattempt' => false,
            'attempt_limit' => 1,
            'show_results' => true,
        ]);

        // 5. INI KUNCINYA: Hubungkan Soal ke Kuis (Pivot Table)
        // Tanpa ini, kuis akan kosong melompong.
        $quiz->questions()->attach($qIds);

        $this->command->info('AlinSeeder: Berhasil membuat data dan menghubungkan soal ke kuis!');
    }
}
