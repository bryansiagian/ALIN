<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserProgress;
use App\Models\UserStreak;
use App\Models\ExamSession;
use App\Models\Topic;
use Illuminate\Support\Facades\DB;

class ProgressController extends Controller
{
    public function getAnalytics(Request $request)
    {
        $user = $request->user();

        // 1. Mengambil semua riwayat sesi ujian mahasiswa
        $sessions = ExamSession::where('user_id', $user->id)
            ->with(['assignment.questions', 'answers'])
            ->latest()
            ->get();

        // 2. Ambil data hasil placement test terbaru dari tabel baru kita
        $placement = DB::table('placement_results')->where('user_id', $user->id)->first();

        // 3. Tentukan status & level adaptif untuk dikirim ke Flutter
        $hasTakenPlacement = $placement ? true : false;
        $unlockedLevel = $placement ? $placement->unlocked_level : 1; // Default level 1 jika belum tes
        $userProgressIndex = $hasTakenPlacement ? 2 : 1; // Logika index topik lama Anda

        return response()->json([
            'streak' => UserStreak::where('user_id', $user->id)->first(),
            'overall_percentage' => 0,
            'completed_topics' => $hasTakenPlacement ? 1 : 0,
            'user_progress_index' => $userProgressIndex,

            // --- DATA BARU UNTUK GAYA DUOLINGO FLUTTER ---
            'has_taken_placement' => $hasTakenPlacement, // Untuk menyembunyikan tombol placement test
            'unlocked_level' => $unlockedLevel,         // Angka gembok level maksimal yang terbuka (1-50)

            'sessions' => $sessions,
        ]);
    }
}
