<?php

namespace App\Livewire\Dosen;

use App\Models\QuestionBank;
use Livewire\Component;
use Livewire\WithPagination;

class PlacementQuestions extends Component
{
    use WithPagination;

    public $search = '';
    public $difficulty_filter = '';

    public function updating($property)
    {
        if (in_array($property, ['search', 'difficulty_filter'])) {
            $this->resetPage();
        }
    }

    public function resetFilters()
    {
        $this->reset(['search', 'difficulty_filter']);
        $this->resetPage();
    }

    public function deleteQuestion($id)
    {
        QuestionBank::where('is_placement', true)->findOrFail($id)->delete();
        session()->flash('success', 'Soal placement berhasil dihapus.');
    }

    public function render()
    {
        $questions = QuestionBank::where('is_placement', true)
            ->when($this->search, fn($q) => $q->where('question_text', 'like', '%' . $this->search . '%'))
            ->when($this->difficulty_filter, fn($q) => $q->where('difficulty', $this->difficulty_filter))
            ->orderByDesc('created_at')
            ->paginate(15);

        return view('livewire.dosen.placement-questions', [
            'questions' => $questions,
        ])->layout('layouts.dosen');
    }
}
