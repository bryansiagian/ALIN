<?php

namespace App\Livewire\Dosen;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class Students extends Component
{
    use WithPagination;

    public $search = '';

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function render()
    {
        $students = User::where('role', 'student')
            ->when($this->search, function ($q) {
                $q->where(function ($q2) {
                    $q2->where('name', 'like', '%' . $this->search . '%')
                        ->orWhere('nim', 'like', '%' . $this->search . '%');
                });
            })
            ->withCount(['examSessions as completed_exams_count' => function ($q) {
                $q->where('status', 'submitted');
            }])
            ->orderBy('name')
            ->paginate(15);

        // Ambil grade placement terbaru per mahasiswa dalam 1 query (hindari N+1)
        $latestPlacements = DB::table('placement_results')
            ->select('user_id', 'grade', 'score', 'unlocked_level')
            ->whereIn('user_id', $students->pluck('id'))
            ->whereIn('id', function ($q) {
                $q->selectRaw('MAX(id)')
                    ->from('placement_results')
                    ->groupBy('user_id');
            })
            ->get()
            ->keyBy('user_id');

        return view('livewire.dosen.students', [
            'students' => $students,
            'latestPlacements' => $latestPlacements,
        ])->layout('layouts.dosen');
    }
}
