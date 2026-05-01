<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\ExamSession;
use App\Models\QuestionBank;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExamController extends Controller
{
    // Mengambil daftar tugas yang belum melewati deadline
    public function getAssignments(Request $request)
    {
        $user = $request->user();
        return Assignment::with('topic')
            ->withCount(['examSessions' => function($q) use ($user) {
                $q->where('user_id', $user->id); // Hanya hitung sesi milik mahasiswa ini
            }])
            ->where('status', 'published')
            ->get();
    }

    // Memulai sesi ujian
    public function startExam(Request $request, $assignmentId)
    {
        try {
            $user = $request->user();
            $assignment = Assignment::with('questions')->findOrFail($assignmentId);

            // 1. Cek apakah ada sesi yang masih 'ongoing' (belum disubmit)
            // Mahasiswa tidak boleh buka sesi baru kalau sesi lama belum selesai
            $activeSession = ExamSession::where('assignment_id', $assignmentId)
                ->where('user_id', $user->id)
                ->where('status', 'ongoing')
                ->first();

            if ($activeSession) {
                return response()->json([
                    'session' => $activeSession,
                    'assignment' => $assignment,
                    'questions' => $assignment->questions
                ]);
            }

            // 2. Hitung jumlah sesi yang sudah 'submitted'
            $completedCount = ExamSession::where('assignment_id', $assignmentId)
                ->where('user_id', $user->id)
                ->where('status', 'submitted')
                ->count();

            // 3. Cek Jatah Percobaan
            if ($completedCount >= $assignment->attempt_limit) {
                return response()->json([
                    'message' => "Jatah percobaan Anda sudah habis ($completedCount/{$assignment->attempt_limit})."
                ], 403);
            }

            // 4. Buat Sesi Baru (Karena jatah masih ada)
            $session = ExamSession::create([
                'assignment_id' => $assignmentId,
                'user_id' => $user->id,
                'started_at' => now(),
                'status' => 'ongoing',
                'violation_count' => 0,
                'is_locked' => false,
                'expired_at' => now()->addMinutes($assignment->duration_minutes)
            ]);

            return response()->json([
                'session' => $session,
                'assignment' => $assignment,
                'questions' => $assignment->questions
            ]);

        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
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
        return DB::transaction(function () use ($request, $sessionId) {
            $session = ExamSession::findOrFail($sessionId);

            // 1. Simpan Jawaban Detail
            $answers = $request->answers; // Map dari Flutter: { "question_id": "A" }
            foreach ($answers as $qId => $ans) {
                $question = QuestionBank::find($qId);
                $isCorrect = $question->correct_answer == $ans;

                \App\Models\ExamAnswer::create([
                    'exam_session_id' => $session->id,
                    'question_id' => $qId,
                    'user_answer' => $ans,
                    'is_correct' => $isCorrect,
                    'score' => $isCorrect ? 1 : 0, // Bobot sederhana
                ]);
            }

            // 2. Update Skor Akhir di Session
            $session->update([
                'submitted_at' => now(),
                'total_score' => $request->total_score,
                'status' => 'submitted'
            ]);

            return response()->json(['message' => 'Sukses menyimpan jawaban']);
        });
    }

    public function getQuestions($id)
    {
        $assignment = Assignment::with('questions')->findOrFail($id);
        return response()->json($assignment->questions);
    }
}
