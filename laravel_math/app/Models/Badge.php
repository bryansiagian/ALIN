<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Badge extends Model
{
    protected $fillable = ['name', 'description', 'icon_url', 'requirement_criteria'];
    protected $casts = ['requirement_criteria' => 'json'];

    public function users() { return $this->belongsToMany(User::class, 'user_badges'); }
}
