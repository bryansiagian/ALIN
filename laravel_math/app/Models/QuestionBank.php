<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuestionBank extends Model
{
    protected $fillable = [
        'topic_id', 'question_text', 'question_type', 'difficulty',
        'options', 'correct_answer', 'explanation'
    ];
    protected $casts = ['options' => 'array'];

    public function topic() { return $this->belongsTo(Topic::class); }
}
