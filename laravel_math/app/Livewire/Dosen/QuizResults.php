<?php

namespace App\Livewire\Dosen;

use App\Models\Assignment;
use Illuminate\Support\Facades\DB;
use Livewire\Component;

class QuizResults extends Component
{
    public Assignment $assignment;
    public $expandedSession = null;

    public function mount($id)
    {
        $this->assignment = Assignment::where('lecturer_id', auth()->id())->findOrFail($id);
    }

    public function toggleExpand($sessionId)
    {
        $this->expandedSession = $this->expandedSession === $sessionId ? null : $sessionId;
    }

    public function render()
    {
        $sessions = DB::table('exam_sessions')
            ->join('users', 'users.id', '=', 'exam_sessions.user_id')
            ->where('exam_sessions.assignment_id', $this->assignment->id)
            ->select(
                'exam_sessions.id',
                'users.name as student_name',
                'users.nim',
                'exam_sessions.total_score',
                'exam_sessions.status',
                'exam_sessions.violation_count',
                'exam_sessions.started_at',
                'exam_sessions.submitted_at'
            )
            ->orderByDesc('exam_sessions.total_score')
            ->get();

        $answers = collect();
        if ($this->expandedSession) {
            $answers = DB::table('exam_answers')
                ->join('question_banks', 'question_banks.id', '=', 'exam_answers.question_id')
                ->where('exam_answers.exam_session_id', $this->expandedSession)
                ->select(
                    'exam_answers.id',
                    'question_banks.question_text',
                    'question_banks.correct_answer',
                    'exam_answers.user_answer',
                    'exam_answers.is_correct',
                    'exam_answers.score'
                )
                ->get();
        }

        $questions = $this->assignment->questions()->get();

        return view('livewire.dosen.quiz-results', [
            'sessions' => $sessions,
            'answers' => $answers,
            'questions' => $questions,
        ])->layout('layouts.dosen');
    }
}
