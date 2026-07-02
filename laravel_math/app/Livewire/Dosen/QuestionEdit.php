<?php

namespace App\Livewire\Dosen;

use App\Models\QuestionBank;
use Livewire\Component;
use Livewire\WithFileUploads;

class QuestionEdit extends Component
{
    use WithFileUploads;

    public QuestionBank $question;

    public $question_text = '';
    public $image = null;
    public $existing_image = null;
    public $options = [];
    public $correct_answer = 'A';

    public function mount($id)
    {
        $this->question = QuestionBank::findOrFail($id);
        $this->question_text = $this->question->question_text;
        $this->existing_image = $this->question->question_image;
        $this->correct_answer = $this->question->correct_answer;

        $rawOptions = $this->question->options ?? [];

        // Deteksi format: list (soal kuis/gamifikasi) vs map asosiatif A/B/C/D (soal placement)
        $isList = array_keys($rawOptions) === range(0, count($rawOptions) - 1);

        if ($isList) {
            foreach ($rawOptions as $opt) {
                $this->options[] = [
                    'key' => $opt['key'] ?? '',
                    'text' => (string) ($opt['text'] ?? ''),
                    'image' => null,
                    'existing_image' => $opt['image'] ?? null,
                ];
            }
        } else {
            // Map asosiatif ['A' => 'teks/angka', 'B' => ..., ...]
            foreach ($rawOptions as $key => $val) {
                $this->options[] = [
                    'key' => $key,
                    'text' => (string) $val,
                    'image' => null,
                    'existing_image' => null,
                ];
            }
        }
    }

    public function removeImage()
    {
        $this->image = null;
        $this->existing_image = null;
    }

    public function removeOptionImage($index)
    {
        $this->options[$index]['image'] = null;
        $this->options[$index]['existing_image'] = null;
    }

    protected function rules()
    {
        return [
            'question_text' => 'required|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'options.*.text' => 'required|string',
            'options.*.image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'correct_answer' => 'required|string',
        ];
    }

    public function save()
    {
        $this->validate();

        $questionImageUrl = $this->existing_image;
        if ($this->image) {
            $path = $this->image->store('question_images', 'public');
            $questionImageUrl = asset('storage/' . $path);
        }

        $options = [];
        foreach ($this->options as $opt) {
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

        $this->question->update([
            'question_text' => $this->question_text,
            'question_image' => $questionImageUrl,
            'options' => $options,
            'correct_answer' => $this->correct_answer,
        ]);

        session()->flash('success', 'Soal berhasil diperbarui!');
        return redirect()->back();
    }

    public function render()
    {
        return view('livewire.dosen.question-edit')->layout('layouts.dosen');
    }
}
