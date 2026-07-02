<?php

namespace App\Livewire\Dosen;

use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class PlacementResults extends Component
{
    use WithPagination;

    public $name = '';
    public $nim = '';
    public $grade_filter = '';

    public function updating($property)
    {
        if (in_array($property, ['name', 'nim', 'grade_filter'])) {
            $this->resetPage();
        }
    }

    public function resetFilters()
    {
        $this->reset(['name', 'nim', 'grade_filter']);
        $this->resetPage();
    }

    public function render()
    {
        $latestIds = DB::table('placement_results')
            ->selectRaw('MAX(id) as id')
            ->groupBy('user_id');

        $query = DB::table('placement_results')
            ->join('users', 'users.id', '=', 'placement_results.user_id')
            ->whereIn('placement_results.id', $latestIds)
            ->when($this->name, fn($q) => $q->where('users.name', 'like', '%' . $this->name . '%'))
            ->when($this->nim, fn($q) => $q->where('users.nim', 'like', '%' . $this->nim . '%'))
            ->when($this->grade_filter, fn($q) => $q->where('placement_results.grade', $this->grade_filter))
            ->select(
                'users.name',
                'users.nim',
                'placement_results.score',
                'placement_results.grade',
                'placement_results.unlocked_level',
                'placement_results.created_at'
            )
            ->orderByDesc('placement_results.score');

        return view('livewire.dosen.placement-results', [
            'results' => $query->paginate(15),
        ])->layout('layouts.dosen');
    }
}
