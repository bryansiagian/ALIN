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
use Carbon\Carbon;

class LecturerController extends Controller
{
    public function index(Request $request)
    {
        try {
            $assignments = Assignment::where('lecturer_id', $request->user()->id)
                ->with('topic')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json($assignments);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Gagal mengambil daftar tugas', 'error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'topic_id'                        => 'required|exists:topics,id|not_in:6',
                'title'                           => 'required|string',
                'start_time'                      => 'required|date',
                'deadline'                        => 'required|date|after:start_time',
                'duration_minutes'                => 'required|integer',
                'is_safe_exam'                    => 'required|boolean',
                'allow_reattempt'                 => 'required|boolean',
                'attempt_limit'                   => 'required|integer|min:1',
                'show_results'                    => 'required|boolean',
                'password'                        => 'nullable|string|max:255',
                'questions'                       => 'required|array|min:1',
                'questions.*.question_text'       => 'required|string',
                'questions.*.question_image'      => 'nullable|string',  // ✅ URL hasil upload
                'questions.*.options'             => 'required|array',
                'questions.*.options.*.key'       => 'required|string',
                'questions.*.options.*.text'      => 'nullable|string',
                'questions.*.options.*.image'     => 'nullable|string',  // ✅ URL gambar opsi
                'questions.*.correct_answer'      => 'required|string',
            ]);

            return DB::transaction(function () use ($request, $validated) {
                $assignment = Assignment::create([
                    'lecturer_id'      => $request->user()->id,
                    'topic_id'         => $validated['topic_id'],
                    'title'            => $validated['title'],
                    'description'      => $request->description ?? '-',
                    'start_time'       => $validated['start_time'],
                    'deadline'         => $validated['deadline'],
                    'duration_minutes' => $validated['duration_minutes'],
                    'question_count'   => count($validated['questions']),
                    'is_safe_exam'     => $validated['is_safe_exam'],
                    'allow_reattempt'  => $validated['allow_reattempt'],
                    'attempt_limit'    => $validated['attempt_limit'],
                    'show_results'     => $validated['show_results'],
                    'status'           => 'published',
                    'password'         => $validated['password'] ?? null,
                ]);

                $questionIds = [];
                foreach ($validated['questions'] as $qData) {
                    $question = QuestionBank::create([
                        'topic_id'       => $validated['topic_id'],
                        'question_text'  => $qData['question_text'],
                        'question_image' => $qData['question_image'] ?? null, // ✅
                        'question_type'  => 'multiple_choice',
                        'difficulty'     => 'medium',
                        'options'        => $qData['options'], // sudah include image per opsi
                        'correct_answer' => $qData['correct_answer'],
                        'is_quiz'        => true,
                    ]);
                    $questionIds[] = $question->id;
                }
                $assignment->questions()->attach($questionIds);

                return response()->json(['message' => 'Kuis berhasil diterbitkan!', 'assignment_id' => $assignment->id], 201);
            });
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function uploadQuestionImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $path = $request->file('image')->store('question_images', 'public');
        $url = asset('storage/' . $path);

        return response()->json(['url' => $url]);
    }

    public function storeQuestion(Request $request)
    {
        $validated = $request->validate([
            'topic_id'       => 'required|exists:topics,id|not_in:6', // PROTEKSI: Cegah ID 6
            'question_text'  => 'required|string',
            'question_type'  => 'required|in:multiple_choice,essay',
            'difficulty'     => 'required|in:easy,medium,hard',
            'options'        => 'required|array',
            'correct_answer' => 'required|string',
            'explanation'    => 'nullable|string',
        ]);

        $question = QuestionBank::create($validated);
        return response()->json(['message' => 'Soal berhasil ditambahkan', 'question' => $question], 201);
    }

    public function uploadQuestionsExcel(Request $request)
    {
        $request->validate(['file' => 'required|file|mimes:xlsx,csv,txt']);

        try {
            // Validasi baris per baris sebelum import
            $data = Excel::toArray(new \App\Imports\QuestionImport, $request->file('file'));
            foreach ($data[0] as $row) {
                if (isset($row['topic_id']) && $row['topic_id'] == 6) {
                    return response()->json(['message' => 'Gagal: Tidak boleh mengupload soal Placement Test via fitur ini!'], 422);
                }
            }

            Excel::import(new \App\Imports\QuestionImport, $request->file('file'));
            return response()->json(['status' => 'success', 'message' => 'Ratusan soal berhasil dimasukkan!'], 200);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => 'Gagal memproses file.', 'error' => $e->getMessage()], 500);
        }
    }

    // --- FUNGSI PENDUKUNG LAINNYA ---

    public function storeTopic(Request $request)
    {
        $validated = $request->validate(['title' => 'required|string|unique:topics,title', 'description' => 'nullable|string']);
        $topic = \App\Models\Topic::create([
            'title' => $validated['title'],
            'slug' => Str::slug($validated['title']),
            'description' => $validated['description'],
            'order_index' => \App\Models\Topic::count() + 1,
            'is_active' => true,
        ]);
        return response()->json($topic, 201);
    }

    public function getTopics()
    {
        return response()->json(\App\Models\Topic::where('id', '!=', 6)->get());
    }

    public function storeMaterial(Request $request)
    {
        $request->validate([
            'topic_id' => 'required|exists:topics,id|not_in:6',
            'title' => 'required|string|max:255',
            'pdf_file' => 'required|mimes:pdf|max:10000',
        ]);
        $path = $request->file('pdf_file')->store('materials', 'public');
        $material = \App\Models\Material::create([
            'topic_id' => $request->topic_id,
            'title' => $request->title,
            'file_path' => $path,
            'content_type' => 'text',
            'order_index' => \App\Models\Material::where('topic_id', $request->topic_id)->count() + 1,
        ]);
        return response()->json(['message' => 'Materi berhasil diupload', 'data' => $material], 201);
    }

    public function updateQuestion(Request $request, $id)
    {
        $request->validate(['question_text' => 'required|string', 'correct_answer' => 'required|string']);
        $question = QuestionBank::findOrFail($id);
        $question->update($request->only(['question_text', 'correct_answer']));
        return response()->json(['message' => 'Soal berhasil diperbarui']);
    }

    public function getResults($id)
    {
        $sessions = ExamSession::where('assignment_id', $id)
            ->with(['user', 'answers.question'])
            ->orderBy('created_at', 'desc')->get();
        return response()->json($sessions->groupBy('user_id'));
    }

    public function getQuestions($id)
    {
        $assignment = Assignment::with('questions')->findOrFail($id);
        return response()->json($assignment->questions);
    }

    public function getStudents()
    {
        return response()->json(User::where('role', 'student')->get());
    }

    public function getStudentDetail($id)
    {
        return response()->json(User::with(['progress.topic', 'examSessions.assignment'])->findOrFail($id));
    }
}
