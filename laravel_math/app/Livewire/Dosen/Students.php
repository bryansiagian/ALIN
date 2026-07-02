<?php

namespace App\Livewire\Dosen;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class Students extends Component
{
    use WithPagination;

    public $name = '';
    public $nim = '';
    public $min_completed = '';
    public $grade_filter = '';
    public $sort_by = 'nim'; // default: urut berdasarkan NIM

    public function updating($property)
    {
        if (in_array($property, ['name', 'nim', 'min_completed', 'grade_filter', 'sort_by'])) {
            $this->resetPage();
        }
    }

    public function resetFilters()
    {
        $this->reset(['name', 'nim', 'min_completed', 'grade_filter']);
        $this->sort_by = 'nim';
        $this->resetPage();
    }

    public function render()
    {
        $latestPlacementIds = DB::table('placement_results')
            ->selectRaw('MAX(id) as id')
            ->groupBy('user_id');

        $query = User::where('role', 'student')
            ->when($this->name, fn($q) => $q->where('name', 'like', '%' . $this->name . '%'))
            ->when($this->nim, fn($q) => $q->where('nim', 'like', '%' . $this->nim . '%'))
            ->withCount(['examSessions as completed_exams_count' => function ($q) {
                $q->where('status', 'submitted');
            }]);

        match ($this->sort_by) {
            'name' => $query->orderBy('name'),
            'nim' => $query->orderBy('nim'),
            default => $query->orderBy('nim'),
        };

        $students = $query->get();

        if ($this->min_completed !== '') {
            $students = $students->filter(fn($s) => $s->completed_exams_count >= (int) $this->min_completed);
        }

        $latestPlacements = DB::table('placement_results')
            ->select('user_id', 'grade', 'score', 'unlocked_level')
            ->whereIn('id', $latestPlacementIds)
            ->get()
            ->keyBy('user_id');

        if ($this->grade_filter !== '') {
            $students = $students->filter(function ($s) use ($latestPlacements) {
                $p = $latestPlacements->get($s->id);
                return $p && $p->grade === $this->grade_filter;
            });
        }

        // Pertahankan urutan hasil query asli (NIM/nama) setelah filter collection
        $students = $students->values();

        $perPage = 15;
        $page = request()->get('page', 1);
        $paged = new \Illuminate\Pagination\LengthAwarePaginator(
            $students->forPage($page, $perPage),
            $students->count(),
            $perPage,
            $page,
            ['path' => request()->url(), 'query' => request()->query()]
        );

        return view('livewire.dosen.students', [
            'students' => $paged,
            'latestPlacements' => $latestPlacements,
        ])->layout('layouts.dosen');
    }
}
