<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = ['name', 'email', 'password', 'role', 'avatar'];

    protected $hidden = ['password', 'remember_token'];

    // Relasi ke Progress Belajar
    public function progress() { return $this->hasMany(UserProgress::class); }

    // Relasi ke Badge (Gamifikasi)
    public function badges() { return $this->belongsToMany(Badge::class, 'user_badges')->withPivot('earned_at'); }

    // Relasi ke Forum
    public function threads() { return $this->hasMany(ForumThread::class); }

    // Relasi ke Ujian
    public function examSessions() { return $this->hasMany(ExamSession::class); }

    // Rumus Favorit
    public function favoriteFormulas() { return $this->belongsToMany(Formula::class, 'user_formula_favorites'); }

    // Streak Harian
    public function streak() { return $this->hasOne(UserStreak::class); }
}
