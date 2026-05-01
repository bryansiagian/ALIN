<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExamSession extends Model
{
    protected $fillable = [
        'assignment_id',
        'user_id',
        'started_at',
        'submitted_at', // Sesuai DBML
        'expired_at',
        'total_score', // Sesuai DBML
        'status',
        'is_locked',
        'violation_count'
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'submitted_at' => 'datetime',
        'expired_at' => 'datetime',
        'is_locked' => 'boolean',
    ];

    public function user() {
        return $this->belongsTo(User::class);
    }

    public function assignment() {
        return $this->belongsTo(Assignment::class);
    }
    
    public function answers() {
        return $this->hasMany(ExamAnswer::class, 'exam_session_id');
    }
}
