<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Dosen\Login;
use App\Livewire\Dosen\Dashboard;
use App\Livewire\Dosen\Topics;
use App\Livewire\Dosen\Materials;
use App\Livewire\Dosen\Quizzes;
use App\Livewire\Dosen\QuizCreate;
use App\Livewire\Dosen\QuizEdit;

Route::get('/', function () {
    return redirect()->route('dosen.login');
});

Route::prefix('dosen')->name('dosen.')->group(function () {
    Route::get('/login', Login::class)->name('login')->middleware('guest');

    Route::middleware(['auth', 'lecturer'])->group(function () {
        Route::get('/dashboard', Dashboard::class)->name('dashboard');
        Route::get('/topics', Topics::class)->name('topics');
        Route::get('/materials', Materials::class)->name('materials');
        Route::get('/quizzes', Quizzes::class)->name('quizzes');
        Route::get('/quizzes/create', QuizCreate::class)->name('quizzes.create');
        Route::get('/quizzes/{id}/edit', QuizEdit::class)->name('quizzes.edit');
        Route::post('/logout', function () {
            auth()->logout();
            request()->session()->invalidate();
            request()->session()->regenerateToken();
            return redirect()->route('dosen.login');
        })->name('logout');
    });
});
