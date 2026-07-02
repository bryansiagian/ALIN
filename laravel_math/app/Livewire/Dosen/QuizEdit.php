<?php

namespace App\Livewire\Dosen;

use App\Models\Assignment;
use App\Models\QuestionBank;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithFileUploads;

class QuizEdit extends Component
{
    use WithFileUploads;

    public Assignment $assignment;

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

    public function mount($id)
    {
        $this->assignment = Assignment::where('lecturer_id', auth()->id())->findOrFail($id);

        $this->title = $this->assignment->title;
        $this->description = $this->assignment->description === '-' ? '' : $this->assignment->description;
        $this->start_time = $this->assignment->start_time ? $this->assignment->start_time->timezone('Asia/Jakarta')->format('Y-m-d\TH:i') : '';
        $this->deadline = $this->assignment->deadline ? $this->assignment->deadline->timezone('Asia/Jakarta')->format('Y-m-d\TH:i') : '';
        $this->is_safe_exam = (bool) $this->assignment->is_safe_exam;
        $this->allow_reattempt = (bool) $this->assignment->allow_reattempt;
        $this->attempt_limit = $this->assignment->attempt_limit;
        $this->show_results = (bool) $this->assignment->show_results;
        $this->password = $this->assignment->password ?? '';

        $questions = $this->assignment->questions()
            ->orderBy('assignment_question.id')
            ->get();

        foreach ($questions as $q) {
            $options = [];
            foreach ($q->options as $opt) {
                $options[] = [
                    'key' => $opt['key'],
                    'text' => $opt['text'],
                    'image' => null,
                    'existing_image' => $opt['image'] ?? null,
                ];
            }

            $this->questions[] = [
                'id' => $q->id,
                'text' => $q->question_text,
                'image' => null,
                'existing_image' => $q->question_image,
                'options' => $options,
                'correct_answer' => $q->correct_answer,
            ];
        }
    }

    public function addQuestion()
    {
        $this->questions[] = [
            'id' => null,
            'text' => '',
            'image' => null,
            'existing_image' => null,
            'options' => [
                ['key' => 'A', 'text' => '', 'image' => null, 'existing_image' => null],
                ['key' => 'B', 'text' => '', 'image' => null, 'existing_image' => null],
                ['key' => 'C', 'text' => '', 'image' => null, 'existing_image' => null],
                ['key' => 'D', 'text' => '', 'image' => null, 'existing_image' => null],
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

    public function removeQuestionImage($index)
    {
        $this->questions[$index]['image'] = null;
        $this->questions[$index]['existing_image'] = null;
    }

    public function removeOptionImage($qIndex, $oIndex)
    {
        $this->questions[$qIndex]['options'][$oIndex]['image'] = null;
        $this->questions[$qIndex]['options'][$oIndex]['existing_image'] = null;
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

    public function update()
    {
        $this->validate();

        DB::transaction(function () {
            $startTime = \Carbon\Carbon::parse($this->start_time, 'Asia/Jakarta')->utc();
            $deadline = \Carbon\Carbon::parse($this->deadline, 'Asia/Jakarta')->utc();

            $this->assignment->update([
                'title' => $this->title,
                'description' => $this->description ?: '-',
                'start_time' => $startTime,
                'deadline' => $deadline,
                'duration_minutes' => $startTime->diffInMinutes($deadline),
                'question_count' => count($this->questions),
                'is_safe_exam' => $this->is_safe_exam,
                'allow_reattempt' => $this->allow_reattempt,
                'attempt_limit' => $this->attempt_limit,
                'show_results' => $this->show_results,
                'password' => $this->password ?: null,
            ]);

            $oldQuestionIds = $this->assignment->questions()->pluck('question_banks.id');
            $this->assignment->questions()->detach();
            QuestionBank::whereIn('id', $oldQuestionIds)->delete();

            $questionIds = [];

            foreach ($this->questions as $q) {
                $questionImageUrl = $q['existing_image'];
                if ($q['image']) {
                    $path = $q['image']->store('question_images', 'public');
                    $questionImageUrl = asset('storage/' . $path);
                }

                $options = [];
                foreach ($q['options'] as $opt) {
                    $optImageUrl = $opt['existing_image'];
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

            $this->assignment->questions()->attach($questionIds);
        });

        session()->flash('success', 'Kuis berhasil diperbarui!');
        return redirect()->route('dosen.quizzes');
    }

    public function render()
    {
        return view('livewire.dosen.quiz-edit')->layout('layouts.dosen');
    }
}
