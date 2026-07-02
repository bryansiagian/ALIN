<?php

namespace App\Livewire\Dosen;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Livewire\Component;

class StudentDetail extends Component
{
    public User $student;

    public function mount($id)
    {
        $this->student = User::where('role', 'student')->findOrFail($id);
    }

    public function render()
    {
        $examSessions = DB::table('exam_sessions')
            ->join('assignments', 'assignments.id', '=', 'exam_sessions.assignment_id')
            ->where('exam_sessions.user_id', $this->student->id)
            ->select(
                'exam_sessions.id',
                'assignments.title as quiz_title',
                'exam_sessions.total_score',
                'exam_sessions.status',
                'exam_sessions.violation_count',
                'exam_sessions.started_at',
                'exam_sessions.submitted_at'
            )
            ->orderByDesc('exam_sessions.created_at')
            ->get();

        $placementHistory = DB::table('placement_results')
            ->where('user_id', $this->student->id)
            ->orderByDesc('created_at')
            ->get();

        return view('livewire.dosen.student-detail', [
            'examSessions' => $examSessions,
            'placementHistory' => $placementHistory,
        ])->layout('layouts.dosen');
    }
}
