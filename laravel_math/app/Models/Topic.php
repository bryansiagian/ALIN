<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Topic extends Model
{
    protected $fillable = [
        'title',
        'slug',
        'description',
        'order_index',
        'is_active'
    ];

    public function materials() { return $this->hasMany(Material::class); }
    public function formulas() { return $this->hasMany(Formula::class); }
    public function assignments() { return $this->hasMany(Assignment::class); }
}
