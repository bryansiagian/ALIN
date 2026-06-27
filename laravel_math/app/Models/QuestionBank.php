<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuestionBank extends Model
{
    protected $fillable = [
        'topic_id',
        'question_text',
        'question_type',
        'difficulty',
        'options',
        'correct_answer',
        'explanation',
        'is_quiz',
        'is_placement'
    ];

    // BARIS INI SANGAT PENTING:
    // Ini memberitahu Laravel untuk otomatis melakukan json_decode
    // saat mengirim data ke API agar Flutter menerimanya sebagai List/Array, bukan String.
    protected $casts = ['options' => 'array'];

    public function topic()
    {
        return $this->belongsTo(Topic::class);
    }

    public function getOptionsAttribute($value)
    {
        // Jika value adalah string JSON, ubah jadi array
        if (is_string($value)) {
            return json_decode($value, true);
        }
        return $value;
    }
}
