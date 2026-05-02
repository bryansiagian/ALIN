<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    protected $fillable = ['topic_id', 'title', 'file_path', 'content_type', 'order_index'];

    protected $appends = ['file_url'];

    public function topic() { return $this->belongsTo(Topic::class); }
    public function getFileUrlAttribute() {
        return $this->file_path ? asset('storage/' . $this->file_path) : null;
    }
}
