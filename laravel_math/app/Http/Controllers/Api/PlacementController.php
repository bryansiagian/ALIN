<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\PlacementResult;
use App\Models\QuestionBank;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlacementController extends Controller
{
    /**
     * Ambil soal placement test.
     * Hanya bisa diakses jika belum pernah mengerjakan placement test.
     */

    /*
    public function getPlacementTest(Request $request)
    {
        $user = $request->user();

        // Tolak jika sudah pernah mengerjakan
        if ($user->has_taken_placement) {
            return response()->json([
                'message' => 'Anda sudah pernah mengerjakan placement test.'
            ], 403);
        }

        // Ambil assignment yang ditandai sebagai placement test
        $assignment = Assignment::with('questions')
            ->where('is_placement', true)
            ->where('status', 'published')
            ->first();

        if (!$assignment) {
            return response()->json([
                'message' => 'Placement test belum tersedia. Hubungi dosen pengampu.'
            ], 404);
        }

        return response()->json([
            'assignment' => $assignment,
            'questions'  => $assignment->questions,
        ]);
    }
    */

    public function getPlacementTest(Request $request)
    {
        // ID 6 adalah ID rak Placement Test yang baru saja kita buat
        $placementTopicId = 6;

        // 1. Mengambil soal dengan filter ganda (Topic ID 6 + Difficulty)
        $easy = \App\Models\QuestionBank::where('topic_id', $placementTopicId)
            ->where('difficulty', 'easy')
            ->inRandomOrder()->limit(3)->get();

        $medium = \App\Models\QuestionBank::where('topic_id', $placementTopicId)
            ->where('difficulty', 'medium')
            ->inRandomOrder()->limit(4)->get();

        $hard = \App\Models\QuestionBank::where('topic_id', $placementTopicId)
            ->where('difficulty', 'hard')
            ->inRandomOrder()->limit(3)->get();

        // 2. Gabungkan hasil dari ketiga kategori
        $questions = $easy->concat($medium)->concat($hard)->shuffle();

        // 3. Pastikan jumlah soal cukup (jika tidak, kirim error)
        if ($questions->count() < 10) {
            return response()->json(['message' => 'Jumlah soal tidak mencukupi di database!'], 404);
        }

        return response()->json([
            'questions' => $questions,
        ]);
    }

    /**
     * Submit jawaban placement test dan hitung grade.
     */
    /*
    public function submitPlacementTest(Request $request)
    {
        $user = $request->user();

        // Tolak jika sudah pernah mengerjakan
        if ($user->has_taken_placement) {
            return response()->json([
                'message' => 'Anda sudah pernah mengerjakan placement test.'
            ], 403);
        }

        $assignment = Assignment::with('questions')
            ->where('is_placement', true)
            ->where('status', 'published')
            ->first();

        if (!$assignment) {
            return response()->json(['message' => 'Placement test tidak ditemukan.'], 404);
        }

        return DB::transaction(function () use ($request, $user, $assignment) {
            // Hitung skor dari jawaban yang dikirim Flutter
            $answers       = $request->answers ?? []; // { "question_id": "A", ... }
            $totalQuestion = $assignment->questions->count();
            $correct       = 0;

            foreach ($assignment->questions as $question) {
                $userAnswer = $answers[$question->id] ?? null;
                if ($userAnswer && $userAnswer === $question->correct_answer) {
                    $correct++;
                }
            }

            // Hitung NA (Nilai Akhir) skala 0-100
            $score = $totalQuestion > 0
                ? round(($correct / $totalQuestion) * 100, 2)
                : 0;

            // Tentukan grade berdasarkan skema dosen
            $grade = $this->determineGrade($score);

            // Simpan hasil placement
            PlacementResult::create([
                'user_id'       => $user->id,
                'assignment_id' => $assignment->id,
                'score'         => $score,
                'grade'         => $grade,
                'taken_at'      => now(),
            ]);

            // Tandai user sudah mengerjakan placement test
            $user->update(['has_taken_placement' => true]);

            return response()->json([
                'score' => $score,
                'grade' => $grade,
                'correct'       => $correct,
                'total'         => $totalQuestion,
                'message'       => 'Placement test berhasil diselesaikan.',
            ]);
        });
    }
    */
    public function submitPlacementTest(Request $request)
    {
        // 1. Validasi input dari Flutter
        $request->validate([
            'answers' => 'required|array',
            'answers.*.question_id' => 'required|exists:question_banks,id',
            'answers.*.selected_option' => 'required|string|max:1',
        ]);

        $answers = $request->input('answers');
        $correctCount = 0;
        $totalQuestions = count($answers);

        // 2. Hitung jumlah jawaban yang benar
        foreach ($answers as $answer) {
            $question = \App\Models\QuestionBank::find($answer['question_id']);

            if ($question && strtoupper($question->correct_answer) === strtoupper($answer['selected_option'])) {
                $correctCount++;
            }
        }

        // 3. Kalkulasi nilai murni (Skor 0 - 100)
        $score = $totalQuestions > 0 ? ($correctCount / $totalQuestions) * 100 : 0;

        // --- PEMBARUAN STRATEGIS: SKEMA BASE-100 SESUAI REVISI ---
        if ($score >= 91) {
            $unlockedLevel = 301; // Awal Bab 4
        } elseif ($score >= 81) {
            $unlockedLevel = 250; // Pertengahan Bab 3
        } elseif ($score >= 71) {
            $unlockedLevel = 201; // Awal Bab 3
        } elseif ($score >= 61) {
            $unlockedLevel = 150; // Pertengahan Bab 2
        } elseif ($score >= 51) {
            $unlockedLevel = 101; // Awal Bab 2
        } elseif ($score >= 41) {
            $unlockedLevel = 50;  // Pertengahan Bab 1
        } else {
            $unlockedLevel = 1;   // Awal Bab 1
        }
        // ---------------------------------------------------------

        // 5. Kunci hasil ke dalam database
        DB::table('placement_results')->insert([
            'user_id' => $request->user()->id,
            'score' => $score,
            'unlocked_level' => $unlockedLevel,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('users')->where('id', $request->user()->id)->update(['has_taken_placement' => true]);

        // 6. Kirim respons balik ke Flutter
        return response()->json([
            'message' => 'Placement test berhasil diselesaikan!',
            'score' => $score,
            'unlocked_level' => $unlockedLevel,
        ], 200);
    }

    /**
     * Ambil hasil placement test milik user yang sedang login.
     * Dipakai Flutter untuk menampilkan grade di profil/home.
     */
    /**
     * Ambil hasil placement test milik user yang sedang login.
     * Dipakai Flutter untuk menampilkan grade di profil/home.
     */
    public function getMyResult(Request $request)
    {
        $user   = $request->user();
        $result = PlacementResult::where('user_id', $user->id)
            // --- PERBAIKAN: Ganti taken_at menjadi created_at ---
            ->latest('created_at')
            // ----------------------------------------------------
            ->first();

        if (!$result) {
            return response()->json(['message' => 'Belum ada hasil placement test.'], 404);
        }

        return response()->json($result);
    }

    /**
     * [DOSEN] Tandai assignment sebagai placement test.
     * Otomatis unset assignment lain yang sebelumnya ditandai.
     */
    public function setPlacementAssignment(Request $request, $assignmentId)
    {
        DB::transaction(function () use ($assignmentId) {
            // Unset semua assignment yang sebelumnya jadi placement
            Assignment::where('is_placement', true)
                ->update(['is_placement' => false]);

            // Set assignment baru sebagai placement
            Assignment::findOrFail($assignmentId)
                ->update(['is_placement' => true]);
        });

        return response()->json([
            'message' => 'Assignment berhasil dijadikan placement test.'
        ]);
    }

    /**
     * Menentukan grade berdasarkan skema penilaian dosen.
     *
     * A  : 79.5 <= NA < 100
     * AB : 72   <= NA < 79.5
     * B  : 64.5 <= NA < 72
     * BC : 57   <= NA < 64.5
     * C  : 49.5 <= NA < 57
     * D  : 34   <= NA < 49.5
     * E  :  0   <= NA < 34
     */
    private function determineGrade(float $score): string
    {
        return match(true) {
            $score >= 79.5 => 'A',
            $score >= 72.0 => 'AB',
            $score >= 64.5 => 'B',
            $score >= 57.0 => 'BC',
            $score >= 49.5 => 'C',
            $score >= 34.0 => 'D',
            default        => 'E',
        };
    }

    public function getLecturerPlacementResults()
    {
        // Ambil semua mahasiswa yang sudah submit placement
        $results = \App\Models\PlacementResult::with('user')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn($r) => [
                'user'  => ['id' => $r->user->id, 'name' => $r->user->name],
                'score' => $r->score,
                'grade' => $r->grade,
            ]);

        return response()->json($results);
    }

    /**
     * Menerjemahkan grade placement menjadi tingkat kesulitan kuis adaptif.
     */
    public static function getAdaptiveDifficulty(string $grade): string
    {
        return match ($grade) {
            'A', 'AB' => 'hard',
            'B', 'BC' => 'medium',
            default   => 'easy',
        };
    }
}
