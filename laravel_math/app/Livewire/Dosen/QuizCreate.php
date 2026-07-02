<?php

namespace App\Livewire\Dosen;

use App\Models\Assignment;
use App\Models\QuestionBank;
use App\Models\Topic;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Livewire\Component;
use Livewire\WithFileUploads;

class QuizCreate extends Component
{
    use WithFileUploads;

    public $title = '';
    public $description = '';
    public $start_time = '';
    public $deadline = '';
    public $is_safe_exam = false;
    public $allow_reattempt = false;
    public $attempt_limit = 1;
    public $show_results = true;
    public $password = '';

    public $questions = [];

    public function mount()
    {
        $this->addQuestion();
    }

    public function addQuestion()
    {
        $this->questions[] = [
            'text' => '',
            'image' => null,
            'options' => [
                ['key' => 'A', 'text' => '', 'image' => null],
                ['key' => 'B', 'text' => '', 'image' => null],
                ['key' => 'C', 'text' => '', 'image' => null],
                ['key' => 'D', 'text' => '', 'image' => null],
            ],
            'correct_answer' => 'A',
        ];
    }

    public function removeQuestion($index)
    {
        if (count($this->questions) <= 1) return;
        unset($this->questions[$index]);
        $this->questions = array_values($this->questions);
    }

    protected function rules()
    {
        return [
            'title' => 'required|string|max:255',
            'start_time' => 'required|date',
            'deadline' => 'required|date|after:start_time',
            'attempt_limit' => 'required|integer|min:1',
            'password' => 'nullable|string|max:255',
            'questions' => 'required|array|min:1',
            'questions.*.text' => 'required|string',
            'questions.*.image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'questions.*.options.*.text' => 'nullable|string',
            'questions.*.options.*.image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'questions.*.correct_answer' => 'required|string',
        ];
    }

    public function save()
    {
        $this->validate();

        DB::transaction(function () {
            $assignment = Assignment::create([
                'lecturer_id' => auth()->id(),
                'topic_id' => 1,
                'title' => $this->title,
                'description' => $this->description ?: '-',
                'start_time' => \Carbon\Carbon::parse($this->start_time, 'Asia/Jakarta')->utc(),
                'deadline' => \Carbon\Carbon::parse($this->deadline, 'Asia/Jakarta')->utc(),
                'duration_minutes' => \Carbon\Carbon::parse($this->start_time, 'Asia/Jakarta')->diffInMinutes(\Carbon\Carbon::parse($this->deadline, 'Asia/Jakarta')),
                'question_count' => count($this->questions),
                'is_safe_exam' => $this->is_safe_exam,
                'allow_reattempt' => $this->allow_reattempt,
                'attempt_limit' => $this->attempt_limit,
                'show_results' => $this->show_results,
                'status' => 'published',
                'password' => $this->password ?: null,
                'is_placement' => false,
            ]);

            $questionIds = [];

            foreach ($this->questions as $q) {
                $questionImageUrl = null;
                if ($q['image']) {
                    $path = $q['image']->store('question_images', 'public');
                    $questionImageUrl = asset('storage/' . $path);
                }

                $options = [];
                foreach ($q['options'] as $opt) {
                    $optImageUrl = null;
                    if ($opt['image']) {
                        $path = $opt['image']->store('question_images', 'public');
                        $optImageUrl = asset('storage/' . $path);
                    }
                    $options[] = [
                        'key' => $opt['key'],
                        'text' => $opt['text'],
                        'image' => $optImageUrl,
                    ];
                }

                $question = QuestionBank::create([
                    'topic_id' => 1,
                    'question_text' => $q['text'],
                    'question_image' => $questionImageUrl,
                    'question_type' => 'multiple_choice',
                    'difficulty' => 'medium',
                    'options' => $options,
                    'correct_answer' => $q['correct_answer'],
                    'is_quiz' => true,
                ]);

                $questionIds[] = $question->id;
            }

            $assignment->questions()->attach($questionIds);
        });

        session()->flash('success', 'Kuis berhasil dibuat!');
        return redirect()->route('dosen.quizzes');
    }

    public function render()
    {
        return view('livewire.dosen.quiz-create')->layout('layouts.dosen');
    }
}
