<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    protected $fillable = [
        'lecturer_id',
        'topic_id',
        'title',
        'description',
        'deadline', // Sesuai DBML
        'duration_minutes',
        'question_count',
        'is_safe_exam',
        'allow_reattempt',
        'attempt_limit',
        'show_results',
        'status',
        'is_placement',
    ];

    protected $casts = [
        'deadline' => 'datetime',
        'is_safe_exam' => 'boolean',
        'allow_reattempt' => 'boolean',
        'show_results' => 'boolean',
        'is_placement'   => 'boolean',
    ];

    public function lecturer()
    {
        return $this->belongsTo(User::class, 'lecturer_id');
    }

    public function topic()
    {
        return $this->belongsTo(Topic::class, 'topic_id');
    }

    public function examSessions() { return $this->hasMany(ExamSession::class); }

    public function questions()
    {
        // Mengacu ke tabel pivot assignment_question
        return $this->belongsToMany(QuestionBank::class, 'assignment_question', 'assignment_id', 'question_id')
                    ->withTimestamps();
    }
}
