<?php

namespace App\Livewire\Dosen;

use App\Models\QuestionBank;
use App\Models\Topic;
use Livewire\Component;
use Livewire\WithPagination;

class GamificationQuestions extends Component
{
    use WithPagination;

    public $search = '';
    public $topic_filter = '';
    public $difficulty_filter = '';

    public function updating($property)
    {
        if (in_array($property, ['search', 'topic_filter', 'difficulty_filter'])) {
            $this->resetPage();
        }
    }

    public function resetFilters()
    {
        $this->reset(['search', 'topic_filter', 'difficulty_filter']);
        $this->resetPage();
    }

    public function deleteQuestion($id)
    {
        QuestionBank::where('is_quiz', false)->where('is_placement', false)->findOrFail($id)->delete();
        session()->flash('success', 'Soal latihan berhasil dihapus.');
    }

    public function render()
    {
        $questions = QuestionBank::where('is_quiz', false)
            ->where('is_placement', false)
            ->with('topic')
            ->when($this->search, fn($q) => $q->where('question_text', 'like', '%' . $this->search . '%'))
            ->when($this->topic_filter, fn($q) => $q->where('topic_id', $this->topic_filter))
            ->when($this->difficulty_filter, fn($q) => $q->where('difficulty', $this->difficulty_filter))
            ->orderBy('topic_id')
            ->orderByDesc('created_at')
            ->paginate(15);

        return view('livewire.dosen.gamification-questions', [
            'questions' => $questions,
            'topics' => Topic::orderBy('title')->get(),
        ])->layout('layouts.dosen');
    }
}
