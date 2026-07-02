<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Dosen\Login;
use App\Livewire\Dosen\Dashboard;
use App\Livewire\Dosen\Topics;

Route::get('/', function () {
    return view('dosen.login');
});

Route::prefix('dosen')->name('dosen.')->group(function () {
    Route::get('/login', Login::class)->name('login')->middleware('guest');

    Route::middleware(['auth', 'lecturer'])->group(function () {
        Route::get('/dashboard', Dashboard::class)->name('dashboard');
        Route::get('/topics', Topics::class)->name('topics');
        Route::post('/logout', function () {
            auth()->logout();
            request()->session()->invalidate();
            request()->session()->regenerateToken();
            return redirect()->route('dosen.login');
        })->name('logout');
    });
});
