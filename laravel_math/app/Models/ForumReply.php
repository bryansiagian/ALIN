<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ForumReply extends Model
{
    protected $fillable = ['thread_id', 'user_id', 'parent_reply_id', 'content'];

    public function thread() { return $this->belongsTo(ForumThread::class); }
    public function user() { return $this->belongsTo(User::class); }

    // Relasi untuk Nested Reply (Balas-balasan)
    public function parent() { return $this->belongsTo(ForumReply::class, 'parent_reply_id'); }
    public function children() { return $this->hasMany(ForumReply::class, 'parent_reply_id'); }
}
