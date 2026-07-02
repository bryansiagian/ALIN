<?php

namespace App\Livewire\Dosen;

use App\Models\Assignment;
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
}
