<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\ExamSession;
use App\Models\QuestionBank;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExamController extends Controller
{
    // Mengambil daftar tugas yang belum melewati deadline
    public function getAssignments()
    {
        $assignments = Assignment::with('topic')
            ->where('deadline', '>', now())
            ->where('status', 'published')
            ->orderBy('deadline', 'asc')
            ->get();

        return response()->json($assignments);
    }

    // Memulai sesi ujian
    public function startExam(Request $request, $assignmentId)
    {
        $user = $request->user();
        $assignment = Assignment::findOrFail($assignmentId);

        // Cek apakah sudah ada sesi, jika belum buat baru
        $session = ExamSession::firstOrCreate(
            ['assignment_id' => $assignmentId, 'user_id' => $user->id],
            [
                'started_at' => now(),
                'status' => 'ongoing',
                'violation_count' => 0,
                'is_locked' => false,
                'expired_at' => now()->addMinutes($assignment->duration_minutes)
            ]
        );

        // Jika sesi sudah pernah di-submit sebelumnya
        if ($session->status === 'submitted') {
            return response()->json(['message' => 'Ujian ini sudah selesai dikerjakan.'], 403);
        }

        // Ambil soal secara acak sesuai question_count yang ditentukan dosen
        $questions = QuestionBank::where('topic_id', $assignment->topic_id)
            ->inRandomOrder()
            ->limit($assignment->question_count)
            ->get();

        return response()->json([
            'session' => $session,
            'assignment' => $assignment,
            'questions' => $questions
        ]);
    }

    // Endpoint Fitur SEB: Melaporkan deteksi screenshot/pindah aplikasi
    public function reportViolation(Request $request, $sessionId)
    {
        $session = ExamSession::findOrFail($sessionId);

        // Tambah hitungan pelanggaran
        $session->increment('violation_count');

        // Logic: Jika pelanggaran lebih dari 3 kali, kunci sesi ujian
        if ($session->violation_count >= 3) {
            $session->update(['is_locked' => true]);
        }

        return response()->json([
            'violation_count' => $session->violation_count,
            'is_locked' => $session->is_locked,
            'message' => 'Pelanggaran tercatat!'
        ]);
    }

    // Menyelesaikan ujian dan mengirim skor
    public function submitExam(Request $request, $sessionId)
    {
        $session = ExamSession::findOrFail($sessionId);

        if ($session->status === 'submitted') {
            return response()->json(['message' => 'Ujian sudah pernah dikirim.'], 403);
        }

        $request->validate([
            'total_score' => 'required|integer|min:0|max:100',
        ]);

        $session->update([
            'submitted_at' => now(),
            'total_score' => $request->total_score,
            'status' => 'submitted'
        ]);

        return response()->json([
            'message' => 'Ujian berhasil dikirim',
            'total_score' => $session->total_score
        ]);
    }
}
