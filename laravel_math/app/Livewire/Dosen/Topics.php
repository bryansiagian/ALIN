<?php

namespace App\Livewire\Dosen;

use App\Models\Topic;
use Illuminate\Support\Str;
use Livewire\Component;

class Topics extends Component
{
    public $showModal = false;
    public $editingId = null;

    public $title = '';
    public $description = '';
    public $is_active = true;

    protected function rules()
    {
        return [
            'title' => 'required|string|max:255|unique:topics,title,' . ($this->editingId ?? 'NULL') . ',id',
            'description' => 'nullable|string',
            'is_active' => 'boolean',
        ];
    }

    public function openCreate()
    {
        $this->reset(['editingId', 'title', 'description']);
        $this->is_active = true;
        $this->showModal = true;
    }

    public function openEdit($id)
    {
        if ($id == 6) {
            session()->flash('error', 'Topik Placement Test tidak dapat diedit.');
            return;
        }

        $topic = Topic::findOrFail($id);
        $this->editingId = $topic->id;
        $this->title = $topic->title;
        $this->description = $topic->description;
        $this->is_active = (bool) $topic->is_active;
        $this->showModal = true;
    }

    public function save()
    {
        $this->validate();

        if ($this->editingId) {
            if ($this->editingId == 6) {
                session()->flash('error', 'Topik Placement Test tidak dapat diedit.');
                $this->showModal = false;
                return;
            }

            $topic = Topic::findOrFail($this->editingId);
            $topic->update([
                'title'       => $this->title,
                'slug'        => Str::slug($this->title),
                'description' => $this->description,
                'is_active'   => $this->is_active,
            ]);
            session()->flash('success', 'Topik berhasil diperbarui.');
        } else {
            Topic::create([
                'title'       => $this->title,
                'slug'        => Str::slug($this->title),
                'description' => $this->description,
                'order_index' => Topic::count() + 1,
                'is_active'   => $this->is_active,
            ]);
            session()->flash('success', 'Topik berhasil ditambahkan.');
        }

        $this->showModal = false;
        $this->reset(['editingId', 'title', 'description']);
    }

    public function delete($id)
    {
        if ($id == 6) {
            session()->flash('error', 'Topik Placement Test tidak dapat dihapus.');
            return;
        }

        $topic = Topic::withCount(['materials', 'assignments', 'formulas'])->findOrFail($id);

        if ($topic->materials_count > 0 || $topic->assignments_count > 0 || $topic->formulas_count > 0) {
            session()->flash('error', 'Topik tidak bisa dihapus karena masih punya materi/kuis/rumus terkait. Hapus dulu isinya.');
            return;
        }

        $topic->delete();
        session()->flash('success', 'Topik berhasil dihapus.');
    }

    public function render()
    {
        $topics = Topic::withCount('materials')->orderBy('order_index')->get();
        return view('livewire.dosen.topics', compact('topics'))->layout('layouts.dosen');
    }
}
