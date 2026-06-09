<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserStreak extends Model
{
    // PERBAIKAN: Samakan nama dengan yang ada di tabel database (last_active_date)
    // Saya juga menambahkan longest_streak agar rekor apinya bisa tersimpan
    protected $fillable = ['user_id', 'current_streak', 'longest_streak', 'last_active_date'];

    protected $casts = ['last_active_date' => 'date'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
