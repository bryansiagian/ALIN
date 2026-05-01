<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ForumThread extends Model
{
    protected $fillable = [
        'user_id',
        'topic_id',
        'title',
        'body', // <--- Ganti 'content' jadi 'body' jika sudah refresh migration
        'image_url',
        'views_count'
    ];

    public function user() { return $this->belongsTo(User::class); }
    public function topic() { return $this->belongsTo(Topic::class); }
    public function replies() { return $this->hasMany(ForumReply::class, 'thread_id'); }
}
