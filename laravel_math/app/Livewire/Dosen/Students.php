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

    public function updating($property)
    {
        if (in_array($property, ['name', 'nim', 'min_completed', 'grade_filter'])) {
            $this->resetPage();
        }
    }

    public function resetFilters()
    {
        $this->reset(['name', 'nim', 'min_completed', 'grade_filter']);
        $this->resetPage();
    }

    public function render()
    {
        // Ambil grade + skor placement TERBARU per mahasiswa (subquery, hindari N+1)
        $latestPlacementIds = DB::table('placement_results')
            ->selectRaw('MAX(id) as id')
            ->groupBy('user_id');

        $query = User::where('role', 'student')
            ->when($this->name, fn($q) => $q->where('name', 'like', '%' . $this->name . '%'))
            ->when($this->nim, fn($q) => $q->where('nim', 'like', '%' . $this->nim . '%'))
            ->withCount(['examSessions as completed_exams_count' => function ($q) {
                $q->where('status', 'submitted');
            }])
            ->when($this->min_completed !== '', function ($q) {
                $q->has('examSessions', '>=', 0); // placeholder agar withCount ter-load; filter asli di bawah via having
            });

        // withCount menghasilkan kolom biasa, bukan relasi, jadi filter angka pakai having via query builder mentah
        $students = $query->orderBy('name')->get();

        if ($this->min_completed !== '') {
            $students = $students->filter(fn($s) => $s->completed_exams_count >= (int) $this->min_completed);
        }

        // Join grade placement terbaru
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

        // Pagination manual karena filter dilakukan di collection, bukan query builder
        $perPage = 15;
        $page = request()->get('page', 1);
        $students = $students->values();
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
