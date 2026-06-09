<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Assignment;
use App\Models\QuestionBank;
use App\Models\User;
use App\Models\ExamSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Maatwebsite\Excel\Facades\Excel;


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
    /*
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'topic_id' => 'required|exists:topics,id',
                'title' => 'required|string',
                'start_time' => 'required|date',
                'deadline' => 'required|date|after:start_time',
                'duration_minutes' => 'required|integer',
                'is_safe_exam' => 'required|boolean',
                'allow_reattempt' => 'required|boolean',
                'attempt_limit' => 'required|integer|min:1',
                'show_results' => 'required|boolean',

                'questions' => 'required|array|min:1',
                'questions.*.question_text' => 'required|string',
                'questions.*.options' => 'required|array',
                'questions.*.correct_answer' => 'required|string',
            ]);

            return DB::transaction(function () use ($request, $validated) {
                $assignment = Assignment::create([
                    'lecturer_id' => $request->user()->id,
                    'topic_id' => $validated['topic_id'],
                    'title' => $validated['title'],
                    'description' => $request->description ?? '-',
                    'start_time' => $request->start_time,
                    'deadline' => $validated['deadline'],
                    'duration_minutes' => $validated['duration_minutes'],
                    'question_count' => count($validated['questions']),
                    'is_safe_exam' => $validated['is_safe_exam'],
                    // MASUKKAN DATA DARI FLUTTER KE DATABASE DI SINI:
                    'allow_reattempt' => $validated['allow_reattempt'],
                    'attempt_limit' => $validated['attempt_limit'],
                    'show_results' => $validated['show_results'],
                    'status' => 'published',
                ]);

                $questionIds = [];
                foreach ($validated['questions'] as $qData) {
                    $question = QuestionBank::create([
                        'topic_id' => $validated['topic_id'],
                        'question_text' => $qData['question_text'],
                        'question_type' => 'multiple_choice',
                        'difficulty' => 'medium',
                        'options' => $qData['options'],
                        'correct_answer' => $qData['correct_answer'],
                    ]);
                    $questionIds[] = $question->id;
                }
                $assignment->questions()->attach($questionIds);

                return response()->json(['message' => 'Kuis berhasil diterbitkan!'], 201);
            });
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    */

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'topic_id' => 'required|exists:topics,id',
                'title' => 'required|string',
                'start_time' => 'required|date',
                'deadline' => 'required|date|after:start_time',
                'duration_minutes' => 'required|integer',
                'is_safe_exam' => 'required|boolean',
                'allow_reattempt' => 'required|boolean',
                'attempt_limit' => 'required|integer|min:1',
                'show_results' => 'required|boolean',

                // PERUBAHAN MUTLAK: Sekarang Mandor hanya meminta daftar Nomor ID Soal (contoh: [1, 2, 3])
                'questions' => 'required|array|min:1',
                'questions.*' => 'required|exists:question_banks,id',
            ]);

            return DB::transaction(function () use ($request, $validated) {
                $assignment = Assignment::create([
                    'lecturer_id' => $request->user()->id,
                    'topic_id' => $validated['topic_id'],
                    'title' => $validated['title'],
                    'description' => $request->description ?? '-',
                    'start_time' => $request->start_time,
                    'deadline' => $validated['deadline'],
                    'duration_minutes' => $validated['duration_minutes'],
                    'question_count' => count($validated['questions']),
                    'is_safe_exam' => $validated['is_safe_exam'],
                    'allow_reattempt' => $validated['allow_reattempt'],
                    'attempt_limit' => $validated['attempt_limit'],
                    'show_results' => $validated['show_results'],
                    'status' => 'published',
                ]);

                // Langsung masukkan daftar soal ke dalam koper tugas
                $assignment->questions()->attach($validated['questions']);

                return response()->json([
                    'message' => 'Kuis berhasil diterbitkan!',
                    'assignment_id' => $assignment->id
                ], 201);
            });
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function storeTopic(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|unique:topics,title',
            'description' => 'nullable|string',
        ]);

        $topic = \App\Models\Topic::create([
            'title' => $validated['title'],
            'slug' => Str::slug($validated['title']),
            'description' => $validated['description'],
            'order_index' => \App\Models\Topic::count() + 1,
            'is_active' => true,
        ]);

        return response()->json($topic, 201);
    }

    public function getTopics() {
        return response()->json(\App\Models\Topic::all());
    }

    // Simpan materi PDF baru
    public function storeMaterial(Request $request)
    {
        $request->validate([
            'topic_id' => 'required|exists:topics,id',
            'title' => 'required|string|max:255',
            'pdf_file' => 'required|mimes:pdf|max:10000', // Max 10MB
        ]);

        // Simpan file ke storage/app/public/materials
        $path = $request->file('pdf_file')->store('materials', 'public');

        $material = \App\Models\Material::create([
            'topic_id' => $request->topic_id,
            'title' => $request->title,
            'file_path' => $path,
            'content_type' => 'text', // Kita beri label text saja atau buat tipe baru 'pdf'
            'order_index' => \App\Models\Material::where('topic_id', $request->topic_id)->count() + 1,
        ]);

        return response()->json(['message' => 'Materi berhasil diupload', 'data' => $material], 201);
    }

    public function storeQuestion(Request $request)
    {
        $validated = $request->validate([
            'topic_id' => 'required|exists:topics,id',
            'question_text' => 'required|string',
            'question_type' => 'required|in:multiple_choice,essay',
            'difficulty' => 'required|in:easy,medium,hard',
            'options' => 'required|array', // Menerima array pilihan A, B, C, D
            'correct_answer' => 'required|string',
            'explanation' => 'nullable|string',
        ]);

        $question = \App\Models\QuestionBank::create($validated);

        return response()->json([
            'message' => 'Soal berhasil ditambahkan ke Bank Soal',
            'question' => $question
        ], 201);
    }

    public function updateQuestion(Request $request, $id)
    {
        $request->validate([
            'question_text' => 'required|string',
            'correct_answer' => 'required|string',
        ]);

        $question = \App\Models\QuestionBank::findOrFail($id);
        $question->update($request->only(['question_text', 'correct_answer']));

        return response()->json(['message' => 'Soal berhasil diperbarui']);
    }

    // Fungsi untuk melihat hasil (Sesuaikan nama dengan route: 'getResults')
    public function getResults($id)
    {
        try {
            // Ambil semua sesi untuk assignment ini
            $sessions = ExamSession::where('assignment_id', $id)
                ->with(['user', 'answers.question'])
                ->orderBy('created_at', 'desc')
                ->get();

            // Kelompokkan berdasarkan user_id
            $grouped = $sessions->groupBy('user_id')->map(function ($userSessions) {
                $user = $userSessions->first()->user;
                return [
                    'user' => $user,
                    'total_attempts' => $userSessions->count(),
                    'highest_score' => $userSessions->max('total_score'),
                    'attempts' => $userSessions // Semua percobaan mahasiswa ini
                ];
            })->values();

            return response()->json($grouped);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function getQuestions($id)
    {
        $assignment = Assignment::with('questions')->findOrFail($id);
        return response()->json($assignment->questions);
    }

    public function getStudents()
    {
        $students = \App\Models\User::where('role', 'student')->get();
        return response()->json($students);
    }

    // Ambil detail progress & nilai kuis mahasiswa tertentu
    public function getStudentDetail($id)
    {
        $student = \App\Models\User::with([
            'progress.topic',
            'examSessions.assignment'
        ])->findOrFail($id);

        return response()->json($student);
    }


    public function uploadQuestionsExcel(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:xlsx,csv|max:2048', // Hanya terima Excel atau CSV
        ]);

        try {
            \Maatwebsite\Excel\Facades\Excel::import(new \App\Imports\QuestionImport, $request->file('file'));

            return response()->json([
                'message' => 'Ratusan soal berhasil dimasukkan ke dalam laci!'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal membaca file Excel.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
