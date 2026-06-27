<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlacementQuestion extends Model
{
    protected $fillable = ['question_text', 'options', 'correct_answer', 'difficulty'];
}
