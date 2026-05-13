<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlacementResult extends Model
{
    protected $fillable = [
        'user_id',
        'assignment_id',
        'score',
        'grade',
        'taken_at',
    ];

    protected $casts = [
        'taken_at' => 'datetime',
        'score'    => 'float',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function assignment(): BelongsTo
    {
        return $this->belongsTo(Assignment::class);
    }
}
