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

        foreach ($this->question->options as $opt) {
            $this->options[] = [
                'key' => $opt['key'],
                'text' => $opt['text'],
                'image' => null,
                'existing_image' => $opt['image'] ?? null,
            ];
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
