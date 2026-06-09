<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LevelController extends Controller
{
    /**
     * Mengambil soal untuk level tertentu (Dinamis 1 - 1000)
     */
    public function getQuestionsByLevel(Request $request, $level)
    {
        $user = $request->user();

        // 1. Validasi batas level agar mahasiswa tidak bisa melompati level yang masih terkunci
        $placement = DB::table('placement_results')->where('user_id', $user->id)->first();
        $maxUnlocked = $placement ? $placement->unlocked_level : 1;

        if ($level > $maxUnlocked) {
            return response()->json(['message' => 'Level ini masih terkunci untuk Anda!'], 403);
        }

        // 2. Algoritma Pemetaan Level ke Urutan Topik (1 Topik = 111 Level)
        $topicOrderIndex = ceil($level / 111);

        // 3. Cari ID asli Topik di database berdasarkan urutannya (order_index)
        $topic = DB::table('topics')
            ->where('is_active', true)
            ->where('id', '!=', 6) // Mengecualikan ID 6 (Topik khusus Placement Test)
            ->orderBy('order_index', 'asc')
            ->skip($topicOrderIndex - 1)
            ->first();

        if (!$topic) {
            return response()->json(['message' => 'Materi untuk level ini belum tersedia.'], 404);
        }

        // 4. Ambil 5 soal secara acak dari bank soal sesuai dengan ID Topik tersebut
        // Gaya Duolingo: Setiap level menyajikan sedikit soal (misal 5 soal) agar cepat selesai
        $questions = DB::table('question_banks')
            ->where('topic_id', $topic->id)
            ->inRandomOrder()
            ->limit(5)
            ->get();

        return response()->json([
            'current_level' => (int)$level,
            'topic_title' => $topic->title,
            'questions' => $questions
        ], 200);
    }

    /**
     * Menyelesaikan soal per level dan memicu kenaikan level otomatis
     */
    public function submitLevelResult(Request $request)
    {
        // 1. Validasi Input dari Flutter
        $request->validate([
            'level' => 'required|integer|min:1',
            'answers' => 'required|array',
            'answers.*.question_id' => 'required|exists:question_banks,id',
            'answers.*.selected_option' => 'required|string|max:1',
        ]);

        $user = $request->user();
        $completedLevel = $request->input('level');
        $answers = $request->input('answers');

        $correctCount = 0;
        $totalQuestions = count($answers);

        // 2. Hitung jumlah jawaban yang benar
        foreach ($answers as $answer) {
            $question = DB::table('question_banks')->where('id', $answer['question_id'])->first();
            if ($question && strtoupper($question->correct_answer) === strtoupper($answer['selected_option'])) {
                $correctCount++;
            }
        }

        // 3. Syarat kelulusan Level Gaya Duolingo: Minimal benar 60% (3 dari 5 soal)
        $score = $totalQuestions > 0 ? ($correctCount / $totalQuestions) * 100 : 0;
        $isPassed = $score >= 60;

        if ($isPassed) {
            // Ambil status level terkini di database
            $placement = DB::table('placement_results')->where('user_id', $user->id)->first();
            $currentUnlockedLevel = $placement ? $placement->unlocked_level : 1;

            // Kenaikan level HANYA terjadi jika level yang diselesaikan adalah level tertinggi saat ini
            if ($completedLevel == $currentUnlockedLevel) {
                $newLevel = $currentUnlockedLevel + 1;

                DB::table('placement_results')
                    ->where('user_id', $user->id)
                    ->update([
                        'unlocked_level' => $newLevel,
                        'updated_at' => now()
                    ]);
            }
        }

        return response()->json([
            'is_passed' => $isPassed,
            'score' => $score,
            'correct_answers' => $correctCount,
            'current_unlocked_level' => DB::table('placement_results')->where('user_id', $user->id)->value('unlocked_level') ?? 1,
            'message' => $isPassed ? 'Selamat! Anda berhasil melewati level ini.' : 'Maaf, Anda gagal. Silakan coba lagi!'
        ], 200);
    }
}
