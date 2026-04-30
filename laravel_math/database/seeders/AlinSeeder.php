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
use Illuminate\Support\Str;

class AlinSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Buat User Dosen (Untuk Lecturer_id di tabel assignments)
        $lecturer = User::create([
            'name' => 'Dr. Aljabar, M.Kom',
            'email' => 'dosen@alin.com',
            'password' => Hash::make('password123'),
            'role' => 'lecturer',
        ]);

        // Buat User Mahasiswa (Untuk Anda login di Flutter nanti)
        User::create([
            'name' => 'Mahasiswa Alin',
            'email' => 'student@alin.com',
            'password' => Hash::make('password123'),
            'role' => 'student',
        ]);

        // 2. Buat Topik Matriks
        $topicMatriks = Topic::create([
            'title' => 'Matriks Dasar',
            'slug' => 'matriks-dasar',
            'description' => 'Mempelajari dasar-dasar matriks, operasi, dan determinan.',
            'order_index' => 1,
            'is_active' => true,
        ]);

        // 3. Buat Materi Interaktif (Fitur 1)
        Material::create([
            'topic_id' => $topicMatriks->id,
            'title' => 'Pengenalan Matriks',
            'content' => 'Matriks adalah susunan bilangan berbentuk baris dan kolom...',
            'content_type' => 'text',
            'order_index' => 1,
        ]);

        // 4. Buat Rumus LaTeX (Fitur 6)
        Formula::create([
            'topic_id' => $topicMatriks->id,
            'title' => 'Determinan Matriks 2x2',
            'latex_expression' => '\det(A) = ad - bc', // Sesuai DBML
            'description' => 'Rumus untuk mencari determinan pada matriks ordo 2x2.',
        ]);

        // 5. Buat Bank Soal (Fitur 9)
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

        QuestionBank::create([
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

        // 6. Buat Penugasan/Quiz (Fitur 12)
        Assignment::create([
            'lecturer_id' => $lecturer->id,
            'topic_id' => $topicMatriks->id,
            'title' => 'Quiz Mingguan: Dasar Matriks',
            'description' => 'Kerjakan quiz ini dengan jujur. Mode SEB Aktif.',
            'deadline' => now()->addDays(7), // Deadline 7 hari ke depan
            'duration_minutes' => 30,
            'question_count' => 2,
            'is_safe_exam' => true, // AKTIFKAN MODE SEB
            'status' => 'published',
        ]);

        $this->command->info('AlinSeeder: Data berhasil dibuat!');
    }
}
