<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\PlacementResult;
use App\Models\QuestionBank;
use App\Models\Topic;
use App\Models\UserProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlacementController extends Controller
{

    // Tambahkan ini di dalam class PlacementController
    public static function getAdaptiveDifficulty(string $grade): string
    {
        return match ($grade) {
            'A'     => 'hard',
            'AB'    => 'hard',
            'B'     => 'medium',
            'BC'    => 'medium',
            'C'     => 'easy',
            'D'     => 'easy',
            default => 'easy',
        };
    }
    /**
     * Ambil soal placement test (10 soal acak dari topik non-placement).
     */
    public function getPlacementTest(Request $request)
    {
        // 1. Hanya ambil soal dari laci "Placement"
        $questions = QuestionBank::where('is_placement', true)
            ->inRandomOrder()
            ->limit(10)
            ->get();

        // 2. Decode opsi jawaban agar aman dibaca Flutter
        foreach ($questions as $q) {
            if (is_string($q->options)) {
                $q->options = json_decode($q->options, true);
            }
        }

        // 3. Validasi jika soal placement kosong
        if ($questions->count() < 1) {
            return response()->json(['message' => 'Soal placement belum tersedia di database!'], 404);
        }

        // 4. Langsung kembalikan soalnya (Jangan ditimpa lagi!)
        return response()->json(['questions' => $questions]);
    }

    /**
     * Submit jawaban placement test dan simpan hasil.
     */
    public function submitPlacementTest(Request $request)
    {
        $request->validate([
            'answers' => 'required|array',
            'answers.*.question_id' => 'required|exists:question_banks,id',
            'answers.*.selected_option' => 'required|string|max:1',
        ]);

        $answers = $request->input('answers');
        $correctCount = 0;
        $totalQuestions = count($answers);

        foreach ($answers as $answer) {
            $question = QuestionBank::find($answer['question_id']);
            if ($question && strtoupper($question->correct_answer) === strtoupper($answer['selected_option'])) {
                $correctCount++;
            }
        }

        $score = $totalQuestions > 0 ? ($correctCount / $totalQuestions) * 100 : 0;
        $grade = $this->determineGrade($score);
        $level = $this->getUnlockedLevel($score);

        $result = new PlacementResult();
        $result->user_id = $request->user()->id;
        $result->score = (float) $score;
        $result->grade = $grade;
        $result->unlocked_level = (int) $level; // PASTIKAN NAMA KOLOM SAMA PERSIS DENGAN DB
        $result->save();

        // Tentukan level berdasarkan skor
        $unlockedLevel = $this->getUnlockedLevel($score);

        // Simpan hasil ke tabel placement_results
        PlacementResult::create([
            'user_id'        => $request->user()->id,
            'score'          => (float) $score,
            'grade'          => $grade ?? 'E', // Beri nilai
            'unlocked_level' => (int) ($unlockedLevel ?? 1),
            'created_at'     => now(),
            'updated_at'     => now(),
        ]);

        // Tandai user sudah mengerjakan
        DB::table('users')->where('id', $request->user()->id)->update(['has_taken_placement' => true]);

        // Update progress user ke topik yang sesuai
        UserProgress::updateOrCreate(
            ['user_id' => $request->user()->id],
            [
                'topic_id' => $this->getTargetTopicId($score),
                'status' => 'in_progress',
                'last_activity' => now(),
            ]
        );

        return response()->json([
            'message' => 'Placement test berhasil diselesaikan!',
            'score' => $score,
            'unlocked_level' => $unlockedLevel,
        ], 200);
    }

    public function getMyResult(Request $request)
    {
        $result = PlacementResult::where('user_id', $request->user()->id)
            ->latest('created_at') // Sudah menggunakan created_at
            ->first();

        if (!$result) {
            return response()->json(['message' => 'Belum ada hasil placement test.'], 404);
        }

        return response()->json($result);
    }

    public function setPlacementAssignment(Request $request, $assignmentId)
    {
        DB::transaction(function () use ($assignmentId) {
            Assignment::where('is_placement', true)->update(['is_placement' => false]);
            Assignment::findOrFail($assignmentId)->update(['is_placement' => true]);
        });

        return response()->json(['message' => 'Assignment berhasil dijadikan placement test.']);
    }

    private function determineGrade(float $score): string
    {
        return match (true) {
            $score >= 79.5 => 'A',
            $score >= 72.0 => 'AB',
            $score >= 64.5 => 'B',
            $score >= 57.0 => 'BC',
            $score >= 49.5 => 'C',
            $score >= 34.0 => 'D',
            default        => 'E',
        };
    }

    private function getUnlockedLevel(float $score): int
    {
        if ($score >= 91) return 301;
        if ($score >= 81) return 250;
        if ($score >= 71) return 201;
        if ($score >= 61) return 150;
        if ($score >= 51) return 101;
        if ($score >= 41) return 50;
        return 1;
    }

    private function getTargetTopicId(float $score): int
    {
        if ($score >= 91) return 4;
        if ($score >= 71) return 3;
        if ($score >= 51) return 2;
        return 1;
    }

    public function getLecturerPlacementResults()
    {
        return response()->json(PlacementResult::with('user')->orderByDesc('created_at')->get());
    }
}
