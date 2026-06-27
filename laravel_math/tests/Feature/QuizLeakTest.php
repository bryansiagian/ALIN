<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Assignment;
use App\Models\Topic;
use App\Models\QuestionBank;
use Illuminate\Foundation\Testing\RefreshDatabase;

class QuizLeakTest extends TestCase
{
    use RefreshDatabase;

    public function test_no_placement_questions_in_quiz()
    {
        // 1. Setup Data Master (Topic)
        Topic::create(['id' => 1, 'title' => 'SPL', 'slug' => 'spl', 'order_index' => 1, 'is_active' => true]);
        Topic::create(['id' => 6, 'title' => 'Placement', 'slug' => 'placement', 'order_index' => 6, 'is_active' => true]);

        // 2. Buat Soal Rutin (Topic 1) dan Soal Placement (Topic 6)
        $soalRutin = QuestionBank::create(['topic_id' => 1, 'question_text' => 'Soal Rutin', 'correct_answer' => 'A', 'difficulty' => 'easy', 'options' => ['A', 'B']]);
        $soalBocor = QuestionBank::create(['topic_id' => 6, 'question_text' => 'Soal Placement', 'correct_answer' => 'A', 'difficulty' => 'easy', 'options' => ['A', 'B']]);

        // 3. Buat Assignment dan hubungkan keduanya
        $assignment = Assignment::create([
            'lecturer_id' => 1,
            'topic_id' => 1,
            'title' => 'Kuis',
            'deadline' => now()->addDays(1),
            'status' => 'published',
            'duration_minutes' => 60,
            'question_count' => 2,
        ]);
        $assignment->questions()->attach([$soalRutin->id, $soalBocor->id]);

        // 4. Jalankan Tes
        $user = User::create(['name' => 'Test', 'email' => 't@t.com', 'password' => bcrypt('123'), 'role' => 'student']);

        $response = $this->actingAs($user)->postJson("/api/exam/{$assignment->id}/start");

        $questions = $response->json('questions');

        // 5. Assertions (Ini yang membuat tes jadi sukses/gagal)
        $this->assertNotEmpty($questions, "Kuis tidak mengembalikan soal!");

        foreach ($questions as $question) {
            $this->assertNotEquals(6, $question['topic_id'], "KEBOCORAN: Soal Placement (ID 6) ditemukan di kuis!");
        }
    }
}
