<?php

namespace App\Livewire\Dosen;

use App\Models\Material;
use App\Models\Topic;
use Illuminate\Support\Facades\Storage;
use Livewire\Component;
use Livewire\WithFileUploads;

class Materials extends Component
{
    use WithFileUploads;

    public $showModal = false;
    public $editingId = null;

    public $topic_id = '';
    public $title = '';
    public $pdf_file = null;

    protected function rules()
    {
        return [
            'topic_id' => 'required|exists:topics,id|not_in:6',
            'title'    => 'required|string|max:255',
            'pdf_file' => ($this->editingId ? 'nullable' : 'required') . '|mimes:pdf|max:10000',
        ];
    }

    protected $messages = [
        'pdf_file.mimes' => 'File harus berformat PDF.',
        'pdf_file.max'   => 'Ukuran file maksimal 10MB.',
    ];

    public function openCreate()
    {
        $this->reset(['editingId', 'topic_id', 'title', 'pdf_file']);
        $this->showModal = true;
    }

    public function openEdit($id)
    {
        $material = Material::findOrFail($id);
        $this->editingId = $material->id;
        $this->topic_id = $material->topic_id;
        $this->title = $material->title;
        $this->pdf_file = null;
        $this->showModal = true;
    }

    public function save()
    {
        $this->validate();

        $data = [
            'topic_id' => $this->topic_id,
            'title'    => $this->title,
        ];

        if ($this->pdf_file) {
            $data['file_path'] = $this->pdf_file->store('materials', 'public');
            $data['content_type'] = 'text';
        }

        if ($this->editingId) {
            $material = Material::findOrFail($this->editingId);

            if ($this->pdf_file && $material->file_path) {
                Storage::disk('public')->delete($material->file_path);
            }

            $material->update($data);
            session()->flash('success', 'Materi berhasil diperbarui.');
        } else {
            $data['order_index'] = Material::where('topic_id', $this->topic_id)->count() + 1;
            Material::create($data);
            session()->flash('success', 'Materi berhasil ditambahkan.');
        }

        $this->showModal = false;
        $this->reset(['editingId', 'topic_id', 'title', 'pdf_file']);
    }

    public function delete($id)
    {
        $material = Material::findOrFail($id);

        if ($material->file_path) {
            Storage::disk('public')->delete($material->file_path);
        }

        $material->delete();
        session()->flash('success', 'Materi berhasil dihapus.');
    }

    public function render()
    {
        $materials = Material::with('topic')->orderBy('topic_id')->orderBy('order_index')->get();
        $topics = Topic::where('id', '!=', 6)->where('is_active', true)->orderBy('order_index')->get();

        return view('livewire.dosen.materials', compact('materials', 'topics'))->layout('layouts.dosen');
    }
}
