<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\QuestionBank;
use App\Models\Topic;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlacementTestFlow extends TestCase
{
    use RefreshDatabase;

    public function test_high_score_unlocks_correct_level_and_filters_quiz_questions()
    {
        // 1. Setup Data Manual (Tanpa factory)
        $user = User::create([
            'name' => 'Test Mahasiswa',
            'email' => 'test@alin.com',
            'password' => bcrypt('password'),
        ]);

        // Pastikan topik DIBUAT DULU
        $topic1 = Topic::create(['id' => 1, 'title' => 'Dasar', 'slug' => 'dasar', 'order_index' => 1, 'is_active' => true]);
        $topic4 = Topic::create(['id' => 4, 'title' => 'Lanjut', 'slug' => 'lanjut', 'order_index' => 4, 'is_active' => true]);

        // Gunakan variabel objek topik agar ID-nya pasti terbaca oleh database
        $materi = QuestionBank::create([
            'topic_id' => $topic4->id, // Menggunakan ID dari objek yang baru dibuat
            'question_text' => 'MATERI',
            'correct_answer' => 'A',
            'is_quiz' => false
        ]);

        QuestionBank::create([
            'topic_id' => $topic4->id, // Menggunakan ID dari objek yang baru dibuat
            'question_text' => 'SOAL KUIS DOSEN',
            'correct_answer' => 'A',
            'is_quiz' => true
        ]);

        // 2. Simulasi submit (Skor 100% agar targetTopicId = 4)
        $this->actingAs($user)->postJson('/api/placement/submit', [
            'answers' => [
                ['question_id' => $materi->id, 'selected_option' => 'A']
            ]
        ]);

        // 3. Tes Progres
        $this->assertDatabaseHas('user_progress', ['user_id' => $user->id, 'topic_id' => 4]);

        // 4. Tes Filter Kuis
        $response = $this->actingAs($user)->getJson('/api/levels/4/questions');
        $response->assertStatus(200);
        $response->assertJsonMissing(['question_text' => 'SOAL KUIS DOSEN']);
    }
}
