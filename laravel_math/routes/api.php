<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\ExamController;
use App\Http\Controllers\Api\GamificationController;
use App\Http\Controllers\Api\ForumController;
use App\Http\Controllers\Api\LecturerController;
use App\Http\Controllers\Api\ProgressController;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Authenticated via Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // User Profile & Auth
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Fitur 1 & 6: Materi & Rumus
    Route::prefix('content')->group(function () {
        Route::get('/topics', [ContentController::class, 'getTopics']);
        Route::get('/topics/{topicId}/materials', [ContentController::class, 'getMaterials']);
        Route::get('/formulas', [ContentController::class, 'getFormulas']);
        Route::post('/formulas/{id}/favorite', [ContentController::class, 'toggleFavoriteFormula']);
    });

    // Fitur 9: Ujian (Student Side - SEB Mode)
    Route::prefix('exam')->group(function () {
        Route::get('/assignments', [ExamController::class, 'getAssignments']);
        Route::post('/assignments/{id}/start', [ExamController::class, 'startExam']);
        Route::post('/sessions/{sessionId}/violation', [ExamController::class, 'reportViolation']);
        Route::post('/sessions/{sessionId}/submit', [ExamController::class, 'submitExam']);
    });

    // Fitur 7 & 8: Progress & Gamifikasi
    Route::get('/leaderboard', [GamificationController::class, 'getLeaderboard']);
    Route::get('/badges', [GamificationController::class, 'getMyBadges']);
    Route::post('/progress/update', [GamificationController::class, 'updateProgress']);

    // Fitur 10: Forum Diskusi
    Route::prefix('forum')->group(function () {
        Route::get('/threads', [ForumController::class, 'getThreads']);
        Route::post('/threads', [ForumController::class, 'storeThread']);
        Route::get('/threads/{id}', [ForumController::class, 'getThreadDetail']);
        Route::post('/threads/{id}/replies', [ForumController::class, 'storeReply']);
    });

    Route::get('/analytics', [ProgressController::class, 'getAnalytics']);

    /*
    |--------------------------------------------------------------------------
    | Lecturer Only Routes
    |--------------------------------------------------------------------------
    */
    Route::middleware(['auth:sanctum', 'is-lecturer'])->prefix('lecturer')->group(function () {
        Route::get('/assignments', [LecturerController::class, 'index']); // Memanggil fungsi index
        Route::post('/assignments', [LecturerController::class, 'store']); // Memanggil fungsi store
        Route::put('/questions/{id}', [LecturerController::class, 'updateQuestion']);
        Route::get('/assignments/{id}/results', [LecturerController::class, 'getResults']); // Memanggil fungsi getResults
        Route::get('/assignments/{id}/questions', [LecturerController::class, 'getQuestions']);
        Route::get('/students', [LecturerController::class, 'getStudents']);
        Route::get('/students/{id}', [LecturerController::class, 'getStudentDetail']);
        Route::get('/topics-list', [LecturerController::class, 'getTopics']); // Untuk dropdown
        Route::post('/topics', [LecturerController::class, 'storeTopic']);     // Untuk simpan topik baru
        Route::post('/materials', [LecturerController::class, 'storeMaterial']); // Untuk upload PDF
    });
});
