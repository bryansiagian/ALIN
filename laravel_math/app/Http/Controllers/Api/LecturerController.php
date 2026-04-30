<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\QuestionBank;
use Illuminate\Http\Request;

class LecturerController extends Controller
{
    // Fungsi untuk mengambil daftar kuis (Ini yang tadi hilang)
    public function index(Request $request)
    {
        try {
            $assignments = Assignment::where('lecturer_id', $request->user()->id)
                ->with('topic') // Pastikan relasi ini sesuai nama fungsi di Model
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($assignments);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal mengambil daftar tugas',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Fungsi untuk menyimpan kuis baru (Sesuaikan nama dengan route: 'store')
    public function store(Request $request)
    {
        $validated = $request->validate([
            'topic_id' => 'required',
            'title' => 'required|string',
            'deadline' => 'required',
            'duration_minutes' => 'required|integer',
            'question_count' => 'required|integer',
            'is_safe_exam' => 'required|boolean',
        ]);

        $assignment = Assignment::create([
            'lecturer_id' => $request->user()->id,
            'topic_id' => $validated['topic_id'],
            'title' => $validated['title'],
            'deadline' => $validated['deadline'],
            'duration_minutes' => $validated['duration_minutes'],
            'question_count' => $validated['question_count'],
            'is_safe_exam' => $validated['is_safe_exam'],
            'status' => 'published',
        ]);

        return response()->json($assignment, 201);
    }

    // Fungsi untuk melihat hasil (Sesuaikan nama dengan route: 'getResults')
    public function getResults($id)
    {
        $assignment = Assignment::with('examSessions.user')->findOrFail($id);
        return response()->json($assignment->examSessions);
    }

    public function getQuestions($id)
    {
        $assignment = Assignment::findOrFail($id);

        // Mengambil soal yang ada di bank soal topik terkait
        $questions = QuestionBank::where('topic_id', $assignment->topic_id)->get();

        return response()->json($questions);
    }
}
