<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Formula extends Model
{
    protected $fillable = [
        'topic_id',
        'title',
        'latex_expression', // Sesuai DBML
        'description'
    ];

    public function topic() { return $this->belongsTo(Topic::class); }
}
