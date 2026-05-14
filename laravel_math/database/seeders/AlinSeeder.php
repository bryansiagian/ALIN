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

        // 2. Buat User Mahasiswa
        $students = [
            ['nim' => '42324001', 'name' => 'Oktova Yoga Praditia Samosir'],
            ['nim' => '42324002', 'name' => 'Brahmana Purba'],
            ['nim' => '42324003', 'name' => 'Kennedi Pane'],
            ['nim' => '42324004', 'name' => 'Johannes Christian Pratama Sitorus'],
            ['nim' => '42324005', 'name' => 'Frans Adriano Sihombing'],
            ['nim' => '42324006', 'name' => 'Tonggi J Simanjuntak'],
            ['nim' => '42324007', 'name' => 'Threenines Laurenz Lubis'],
            ['nim' => '42324008', 'name' => 'Monica Putri Lestari Panjaitan'],
            ['nim' => '42324009', 'name' => 'Natasya Magdalena Tambunan'],
            ['nim' => '42324010', 'name' => 'Anggi Simanjuntak'],
            ['nim' => '42324011', 'name' => 'Gresia Delia Silalahi'],
            ['nim' => '42324012', 'name' => 'Gracelita Patricia Hutauruk'],
            ['nim' => '42324013', 'name' => 'Beta Kristien Manullang'],
            ['nim' => '42324015', 'name' => 'Daniel Sahputra Manurung'],
            ['nim' => '42324016', 'name' => 'Glory Gratia Geraldine'],
            ['nim' => '42324017', 'name' => 'Airin Olga Chelsea Sitompul'],
            ['nim' => '42324018', 'name' => 'Tiara Ananda Pardosi'],
            ['nim' => '42324019', 'name' => 'Joy Marthin Aruan'],
            ['nim' => '42324020', 'name' => 'Chrisman Pangeran Toga Butar Butar'],
            ['nim' => '42324022', 'name' => 'Hesekiel Josafat Marbun'],
            ['nim' => '42324023', 'name' => 'Mikhael Josua Roganda'],
            ['nim' => '42324024', 'name' => 'Eben Haezer Manurung'],
            ['nim' => '42324025', 'name' => 'Tika Altiora Sitanggang'],
            ['nim' => '42324026', 'name' => 'Epiphania Christin Simanjuntak'],
            ['nim' => '42324027', 'name' => 'Laura Aurelia'],
            ['nim' => '42324028', 'name' => 'Citra M. Sidabutar'],
            ['nim' => '42324029', 'name' => 'Bryan Torisi Siagian'],
            ['nim' => '42324030', 'name' => 'Rido Jeremi Siagian'],
            ['nim' => '42324031', 'name' => 'Steven Simanjuntak'],
            ['nim' => '42324032', 'name' => 'Aldo Steven Dion Sitorus'],
            ['nim' => '42324033', 'name' => 'Rizky Immanuel Siburian'],
            ['nim' => '42324034', 'name' => 'Reinsan Paulus Efendi Panjaitan'],
            ['nim' => '42324035', 'name' => 'Don Bosco.G V Simorangkir'],
            ['nim' => '42324036', 'name' => 'Yosafat Gumilang Doloksaribu'],
            ['nim' => '42324037', 'name' => 'Ruben Sibarani'],
            ['nim' => '42324038', 'name' => 'Aditia Xaverius Arapenta Tarigan'],
            ['nim' => '42324039', 'name' => 'Gabe Akasia Simanjuntak'],
            ['nim' => '42324040', 'name' => 'Greis Juniwaty Lumbantoruan'],
            ['nim' => '42324041', 'name' => 'Felicya Panjaitan'],
            ['nim' => '42324042', 'name' => 'Tamara Pierda T. Sinaga'],
            ['nim' => '42324043', 'name' => 'Sophia Melisa Silitonga'],
            ['nim' => '42324044', 'name' => 'Mutiara Christin Marpaung'],
            ['nim' => '42324045', 'name' => 'Fani Namesia R. Sianturi'],
            ['nim' => '42324046', 'name' => 'Ellyzhabeth'],
            ['nim' => '42324047', 'name' => 'Februwati Silalahi'],
            ['nim' => '42324048', 'name' => 'Tiur Juliana Sitorus'],
            ['nim' => '42324049', 'name' => 'Sara Tesalonika Rajagukguk'],
            ['nim' => '42324050', 'name' => 'Joys Lamlam Dominiq Christy Tampubolon'],
            ['nim' => '42324052', 'name' => 'Debora Febrianti Tampubolon'],
            ['nim' => '42324053', 'name' => 'Monica Sitanggang'],
            ['nim' => '42324054', 'name' => 'Kesia Khayana Margareth Barasa'],
            ['nim' => '42324055', 'name' => 'Celine Tamara Geraldine Aritonang'],
            ['nim' => '42324056', 'name' => 'Christina Adelia Sitinjak'],
            ['nim' => '42324057', 'name' => 'Anggi F. A. Br Sembiring'],
            ['nim' => '42324058', 'name' => 'Maria Christin Gurning'],
            ['nim' => '42324059', 'name' => 'Joyce Paulina Simanjuntak'],
            ['nim' => '42324060', 'name' => 'Maria Cicilia Pratama Tampubolon'],
            ['nim' => '42324061', 'name' => 'Lidya Yuliana Sinaga'],
            ['nim' => '42324062', 'name' => 'Michelle Sianturi'],
        ];

        foreach ($students as $student) {
            $firstName = strtolower(explode(' ', $student['name'])[0]);
            $lastThreeNim = substr($student['nim'], -3);
            $password = $firstName . $lastThreeNim;

            User::create([
                'name' => $student['name'],
                'email' => $student['nim'] . '@alin.com',
                'password' => Hash::make($password),
                'role' => 'student',
                'nim' => $student['nim'],
                'prodi' => 'DIII Teknologi Informasi',
            ]);
        }

        // 3. Buat Topik Matriks
        $topicMatriks = Topic::create([
            'title' => 'Matriks Dasar',
            'slug' => 'matriks-dasar',
            'description' => 'Mempelajari dasar-dasar matriks, operasi, dan determinan.',
            'order_index' => 1,
            'is_active' => true,
        ]);

        // 4. Buat Soal-soal
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

        // 5. Buat Penugasan/Quiz
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
            'allow_reattempt' => false,
            'attempt_limit' => 1,
            'show_results' => true,
        ]);

        $quiz->questions()->attach($qIds);

        $this->command->info('AlinSeeder: Berhasil membuat ' . count($students) . ' mahasiswa!');
    }
} 
