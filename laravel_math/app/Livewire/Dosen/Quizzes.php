<?php

namespace App\Livewire\Dosen;

use App\Models\Assignment;
use App\Models\QuestionBank;
use Livewire\Component;

class Quizzes extends Component
{
    public function render()
    {
        $quizzes = Assignment::where('lecturer_id', auth()->id())
            ->where('is_placement', false)
            ->with('topic')
            ->withCount('examSessions')
            ->orderBy('created_at', 'desc')
            ->get();

        return view('livewire.dosen.quizzes', compact('quizzes'))->layout('layouts.dosen');
    }

    public function deleteQuiz($id)
    {
        $quiz = Assignment::where('lecturer_id', auth()->id())->findOrFail($id);

        $questionIds = $quiz->questions()->pluck('question_banks.id');
        $quiz->questions()->detach();
        QuestionBank::whereIn('id', $questionIds)->delete();
        $quiz->delete();

        session()->flash('success', 'Kuis berhasil dihapus.');
    }
}
