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
        'status'
    ];

    protected $casts = [
        'deadline' => 'datetime',
        'is_safe_exam' => 'boolean',
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
}
