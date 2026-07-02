<?php

namespace App\Livewire\Dosen;

use App\Imports\PlacementImport;
use App\Imports\QuestionImport as ExcelQuestionImport;
use Livewire\Component;
use Livewire\WithFileUploads;
use Maatwebsite\Excel\Facades\Excel;

class QuestionImport extends Component
{
    use WithFileUploads;

    public $placement_file;
    public $gamification_file;
    public $gamification_topic_id = '';

    public $placement_message = null;
    public $gamification_message = null;

    public function importPlacement()
    {
        $this->validate([
            'placement_file' => 'required|mimes:csv,txt,xlsx,xls|max:5120',
        ]);

        try {
            Excel::import(new PlacementImport(), $this->placement_file->getRealPath());
            $this->placement_message = ['type' => 'success', 'text' => 'Soal placement berhasil diimport.'];
        } catch (\Exception $e) {
            $this->placement_message = ['type' => 'error', 'text' => 'Gagal: ' . $e->getMessage()];
        }

        $this->placement_file = null;
    }

    public function importGamification()
    {
        $this->validate([
            'gamification_file' => 'required|mimes:csv,txt,xlsx,xls|max:5120',
            'gamification_topic_id' => 'required|exists:topics,id',
        ]);

        try {
            Excel::import(new ExcelQuestionImport($this->gamification_topic_id), $this->gamification_file->getRealPath());
            $this->gamification_message = ['type' => 'success', 'text' => 'Soal berhasil diimport.'];
        } catch (\Exception $e) {
            $this->gamification_message = ['type' => 'error', 'text' => 'Gagal: ' . $e->getMessage()];
        }

        $this->gamification_file = null;
    }

    public function render()
    {
        return view('livewire.dosen.question-import', [
            'topics' => \App\Models\Topic::orderBy('title')->get(),
        ])->layout('layouts.dosen');
    }
}
