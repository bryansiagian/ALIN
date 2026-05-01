<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ExamAnswer extends Model {
    protected $fillable = ['exam_session_id', 'question_id', 'user_answer', 'is_correct', 'score'];

    public function question() {
        return $this->belongsTo(QuestionBank::class, 'question_id');
    }
}
