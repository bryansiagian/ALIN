<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    protected $fillable = ['topic_id', 'title', 'content', 'content_type', 'order_index'];

    public function topic() { return $this->belongsTo(Topic::class); }
}
