<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserProgress;
use App\Models\UserStreak;
use App\Models\ExamSession; // Pastikan ini di-import
use App\Models\Topic;

class ProgressController extends Controller
{
    public function getAnalytics(Request $request)
    {
        $user = $request->user();

        // Pastikan mengambil SEMUA sesi ujian, bukan diringkas
        $sessions = \App\Models\ExamSession::where('user_id', $user->id)
            ->with(['assignment.questions', 'answers'])
            ->latest() // Yang terbaru di atas
            ->get();

        return response()->json([
            'streak' => \App\Models\UserStreak::where('user_id', $user->id)->first(),
            'overall_percentage' => 0, // Abaikan dulu hitungan ini
            'completed_topics' => 0,   // Abaikan dulu hitungan ini
            'sessions' => $sessions,   // INI YANG DITAMPILKAN DI LIST
        ]);
    }
}
