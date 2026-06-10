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
        $sessions = \App\Models\ExamSession::where('user_id', $user->id)
            ->with(['assignment.questions', 'answers'])
            ->latest()
            ->get();

        // 2. Intip data hasil placement test terbaru dari tabel khusus
        $placement = DB::table('placement_results')->where('user_id', $user->id)->first();

        // 3. Logika Penentuan Status & Level Adaptif Berbasis Base-100
        $hasTakenPlacement = $placement ? true : false;
        $unlockedLevel = $placement ? $placement->unlocked_level : 1; // Default level 1 jika belum tes

        // Hitung secara otomatis, mahasiswa berada di Bab aktif nomor berapa (1 - 9)
        // Misal: Level 250 -> ceil(250 / 100) = Bab 3 Aktif.
        $userProgressIndex = ceil($unlockedLevel / 100);

        return response()->json([
            'streak' => \App\Models\UserStreak::where('user_id', $user->id)->first(),
            'overall_percentage' => 0,
            'completed_topics' => $hasTakenPlacement ? $userProgressIndex - 1 : 0,

            // --- VARIABEL KUNCI UNTUK KINERJA REAKTIF FLUTTER ---
            'user_progress_index' => $userProgressIndex, // Menentukan gembok folder Bab Besar (1 - 9)
            'unlocked_level' => (int)$unlockedLevel,     // Menentukan level maksimal di dalam Sub-Screen
            'has_taken_placement' => $hasTakenPlacement,

            'sessions' => $sessions,
        ]);
    }
}
