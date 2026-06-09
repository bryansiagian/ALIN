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
    /**
     * Mengambil daftar tugas yang sudah dipublikasikan,
     * beserta jumlah sesi yang sudah dikerjakan mahasiswa ini.
     */
    public function getAssignments(Request $request)
    {
        $user = $request->user();

        return Assignment::with('topic')
            ->withCount(['examSessions' => function ($q) use ($user) {
                $q->where('user_id', $user->id);
            }])
            ->where('status', 'published')
            ->get();
    }

    /**
     * Memulai sesi ujian baru, atau mengembalikan sesi ongoing jika ada.
     */
    public function startExam(Request $request, $assignmentId)
    {
        try {
            $user       = $request->user();
            $assignment = Assignment::with('questions')->findOrFail($assignmentId);

            $sekarang = now();

            if ($assignment->start_time && $sekarang->lessThan($assignment->start_time)) {
                return response()->json([
                    'message' => 'Ujian belum dimulai. Silakan tunggu sampai waktu yang ditentukan.'
                ], 403);
            }

            if ($assignment->deadline && $sekarang->greaterThan($assignment->deadline)) {
                return response()->json([
                    'message' => 'Waktu ujian sudah berakhir. Anda tidak bisa lagi mengakses ujian ini.'
                ], 403);
            }

            // --- LOGIKA PEMBELAJARAN ADAPTIF (ADAPTIVE LEARNING) ---
            // 1. Intip rapor ujian penempatan milik mahasiswa ini
            $placement = \App\Models\PlacementResult::where('user_id', $user->id)->first();

            // 2. Tentukan jalur kesulitannya menggunakan fungsi yang tadi kita buat
            // Jika dia belum ikut placement (atau ini kuis biasa tanpa syarat), paksa ke jalur 'easy'
            $tier = $placement
                ? \App\Http\Controllers\Api\PlacementController::getAdaptiveDifficulty($placement->grade)
                : 'easy';

            // 3. Filter soal di dalam Koper ini agar HANYA mengeluarkan soal sesuai levelnya
            $adaptiveQuestions = $assignment->questions()->where('difficulty', $tier)->inRandomOrder()->get();

            // 4. PERTAHANAN SISTEM: Jika Dosen lupa memasukkan soal dengan tingkat kesulitan tersebut,
            // keluarkan saja semua soal yang ada agar layar Flutter tidak nge-blank (crash).
            if ($adaptiveQuestions->isEmpty()) {
                $adaptiveQuestions = $assignment->questions;
            }
            // --------------------------------------------------------

            // Cek apakah ada sesi ongoing yang belum disubmit
            $activeSession = ExamSession::where('assignment_id', $assignmentId)
                ->where('user_id', $user->id)
                ->where('status', 'ongoing')
                ->first();

            if ($activeSession) {
                if ($activeSession->is_locked) {
                    return response()->json([
                        'message' => 'Sesi ujian Anda telah dikunci karena pelanggaran.'
                    ], 403);
                }

                return response()->json([
                    'session'    => $activeSession,
                    'assignment' => $assignment,
                    'questions'  => $adaptiveQuestions, // Gunakan soal yang sudah disaring!
                ]);
            }

            // Hitung percobaan yang sudah selesai
            $completedCount = ExamSession::where('assignment_id', $assignmentId)
                ->where('user_id', $user->id)
                ->where('status', 'submitted')
                ->count();

            // Cek jatah percobaan
            if ($completedCount >= $assignment->attempt_limit) {
                return response()->json([
                    'message' => "Jatah percobaan Anda sudah habis ({$completedCount}/{$assignment->attempt_limit})."
                ], 403);
            }

            // Buat sesi baru
            $session = ExamSession::create([
                'assignment_id'   => $assignmentId,
                'user_id'         => $user->id,
                'started_at'      => now(),
                'status'          => 'ongoing',
                'violation_count' => 0,
                'is_locked'       => false,
                'expired_at'      => now()->addMinutes($assignment->duration_minutes),
            ]);

            return response()->json([
                'session'    => $session,
                'assignment' => $assignment,
                'questions'  => $adaptiveQuestions, // Gunakan soal yang sudah disaring!
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Melaporkan pelanggaran (screenshot / pindah app).
     * Langsung submit skor 0 saat pelanggaran pertama.
     */
    public function reportViolation(Request $request, $sessionId)
    {
        $session = ExamSession::findOrFail($sessionId);

        // Jika sudah disubmit (karena pelanggaran sebelumnya), abaikan
        if ($session->status === 'submitted') {
            return response()->json([
                'violation_count' => $session->violation_count,
                'is_locked'       => true,
                'message'         => 'Sesi sudah selesai.',
            ]);
        }

        // Langsung submit skor 0 pada pelanggaran pertama
        $session->increment('violation_count');

        DB::transaction(function () use ($session) {
            $session->update([
                'is_locked'    => true,
                'total_score'  => 0,
                'submitted_at' => now(),
                'status'       => 'submitted',
            ]);
        });

        return response()->json([
            'violation_count' => $session->violation_count,
            'is_locked'       => true,
            'message'         => 'Pelanggaran terdeteksi! Ujian otomatis dinilai 0.',
        ]);
    }

    /**
     * Menyimpan jawaban dan menyelesaikan ujian.
     * Menolak submit jika sesi dikunci atau sudah submitted.
     */
    public function submitExam(Request $request, $sessionId)
    {
        return DB::transaction(function () use ($request, $sessionId) {
            $session = ExamSession::findOrFail($sessionId);

            // Tolak jika sesi sudah auto-submit karena pelanggaran
            if ($session->is_locked) {
                return response()->json([
                    'message' => 'Ujian telah otomatis dinilai 0 karena pelanggaran.'
                ], 403);
            }

            // Tolak jika sudah disubmit sebelumnya (idempotency guard)
            if ($session->status === 'submitted') {
                return response()->json([
                    'message' => 'Ujian sudah pernah disubmit.'
                ], 409);
            }

            // 1. Simpan jawaban detail
            $answers = $request->answers ?? [];
            foreach ($answers as $qId => $ans) {
                $question  = QuestionBank::find($qId);
                $isCorrect = $question && $question->correct_answer === $ans;

                \App\Models\ExamAnswer::create([
                    'exam_session_id' => $session->id,
                    'question_id'     => $qId,
                    'user_answer'     => $ans,
                    'is_correct'      => $isCorrect,
                    'score'           => $isCorrect ? 1 : 0,
                ]);
            }

            // 2. Update skor akhir
            $session->update([
                'submitted_at' => now(),
                'total_score'  => $request->total_score ?? 0,
                'status'       => 'submitted',
            ]);

            // 3. LOGIKA STREAK HARIAN (BUKU ABSEN)
            $hariIni = now()->toDateString();
            $streak = \App\Models\UserStreak::firstOrCreate(
                ['user_id' => $session->user_id],
                ['current_streak' => 0, 'longest_streak' => 0, 'last_active_date' => null]
            );

            // Jika dia belum pernah belajar, atau terakhir belajar sebelum hari ini
            if ($streak->last_active_date !== $hariIni) {
                // Cek apakah terakhir belajar adalah KEMARIN (lanjutkan api)
                if ($streak->last_active_date === now()->subDay()->toDateString()) {
                    $streak->current_streak += 1;
                } else {
                    // Bolos, api reset dari 1
                    $streak->current_streak = 1;
                }

                // Cek rekor terpanjang
                if ($streak->current_streak > $streak->longest_streak) {
                    $streak->longest_streak = $streak->current_streak;
                }

                $streak->last_active_date = $hariIni;
                $streak->save();
            }

            return response()->json(['message' => 'Jawaban berhasil disimpan.']);
        });
    }

    /**
     * Mengambil daftar soal dari sebuah assignment (untuk dosen).
     */
    public function getQuestions($id)
    {
        $assignment = Assignment::with('questions')->findOrFail($id);
        return response()->json($assignment->questions);
    }
}
