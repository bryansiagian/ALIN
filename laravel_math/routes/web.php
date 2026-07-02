<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Dosen\Login;
use App\Livewire\Dosen\Dashboard;
use App\Livewire\Dosen\Topics;
use App\Livewire\Dosen\Materials;
use App\Livewire\Dosen\Quizzes;
use App\Livewire\Dosen\QuizCreate;
use App\Livewire\Dosen\QuizEdit;
use App\Livewire\Dosen\QuestionImport;
use App\Livewire\Dosen\Students;
use App\Livewire\Dosen\StudentDetail;
use App\Livewire\Dosen\QuizResults;
use App\Livewire\Dosen\PlacementResults;
use App\Livewire\Dosen\QuestionEdit;
use App\Livewire\Dosen\PlacementQuestions;
use App\Livewire\Dosen\GamificationQuestions;

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
        Route::get('/questions/import', QuestionImport::class)->name('questions.import');
        Route::get('/students', Students::class)->name('students');
        Route::get('/students/{id}', StudentDetail::class)->name('students.detail');
        Route::get('/quizzes/{id}/results', QuizResults::class)->name('quizzes.results');
        Route::get('/placement/results', PlacementResults::class)->name('placement.results');
        Route::get('/questions/{id}/edit', QuestionEdit::class)->name('questions.edit');
        Route::get('/placement-questions', PlacementQuestions::class)->name('placement-questions');
        Route::get('/gamification-questions', GamificationQuestions::class)->name('gamification-questions');
        Route::post('/logout', function () {
            auth()->logout();
            request()->session()->invalidate();
            request()->session()->regenerateToken();
            return redirect()->route('dosen.login');
        })->name('logout');
    });
});
