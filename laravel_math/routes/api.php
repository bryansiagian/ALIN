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
use App\Http\Controllers\Api\PlacementController;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Authenticated via Sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    Route::get('/levels/{level}/questions', [App\Http\Controllers\Api\LevelController::class, 'getQuestionsByLevel']);
    Route::post('/levels/submit', [App\Http\Controllers\Api\LevelController::class, 'submitLevelResult']);

    // User Profile & Auth
    Route::get('/me',     [AuthController::class, 'me']);
    Route::post('/logout',[AuthController::class, 'logout']);

    // ── Placement Test (Student) ──────────────────────────────────────
    Route::prefix('placement')->group(function () {
        Route::get('/',       [PlacementController::class, 'getPlacementTest']);   // Ambil soal
        Route::post('/submit',[PlacementController::class, 'submitPlacementTest']); // Submit jawaban
        Route::get('/result', [PlacementController::class, 'getMyResult']);         // Ambil hasil
    });

    // Fitur 1 & 6: Materi & Rumus
    Route::prefix('content')->group(function () {
        Route::get('/topics',                       [ContentController::class, 'getTopics']);
        Route::get('/topics/{topicId}/materials',   [ContentController::class, 'getMaterials']);
        Route::get('/formulas',                     [ContentController::class, 'getFormulas']);
        Route::post('/formulas/{id}/favorite',      [ContentController::class, 'toggleFavoriteFormula']);
        Route::get('/materials/base64/{filename}',  [ContentController::class, 'downloadMaterialBase64']);
    });

    // Fitur 9: Ujian (Student Side - SEB Mode)
    Route::prefix('exam')->group(function () {
        Route::get('/assignments',                          [ExamController::class, 'getAssignments']);
        Route::post('/assignments/{id}/start',              [ExamController::class, 'startExam']);
        Route::post('/sessions/{sessionId}/violation',      [ExamController::class, 'reportViolation']);
        Route::post('/sessions/{sessionId}/submit',         [ExamController::class, 'submitExam']);
    });

    // Fitur 7 & 8: Progress & Gamifikasi
    Route::get('/leaderboard',       [GamificationController::class, 'getLeaderboard']);
    Route::get('/badges',            [GamificationController::class, 'getMyBadges']);
    Route::post('/progress/update',  [GamificationController::class, 'updateProgress']);

    // Fitur 10: Forum Diskusi
    Route::prefix('forum')->group(function () {
        Route::get('/threads',              [ForumController::class, 'getThreads']);
        Route::post('/threads',             [ForumController::class, 'storeThread']);
        Route::get('/threads/{id}',         [ForumController::class, 'getThreadDetail']);
        Route::post('/threads/{id}/replies',[ForumController::class, 'storeReply']);
    });

    Route::get('/analytics', [ProgressController::class, 'getAnalytics']);

    /*
    |--------------------------------------------------------------------------
    | Lecturer Only Routes
    |--------------------------------------------------------------------------
    */
    Route::middleware('is-lecturer')->prefix('lecturer')->group(function () {
        Route::get('/assignments',              [LecturerController::class, 'index']);
        Route::post('/assignments',             [LecturerController::class, 'store']);
        Route::post('/upload-image',   [LecturerController::class, 'uploadQuestionImage']);
        Route::put('/questions/{id}',           [LecturerController::class, 'updateQuestion']);
        Route::get('/assignments/{id}/results', [LecturerController::class, 'getResults']);
        Route::get('/assignments/{id}/questions',[LecturerController::class, 'getQuestions']);
        Route::get('/students',                 [LecturerController::class, 'getStudents']);
        Route::get('/students/{id}',            [LecturerController::class, 'getStudentDetail']);
        Route::get('/topics-list',              [LecturerController::class, 'getTopics']);
        Route::post('/topics',                  [LecturerController::class, 'storeTopic']);
        Route::post('/materials',               [LecturerController::class, 'storeMaterial']);
        Route::post('/assignments/{id}/set-placement', [PlacementController::class, 'setPlacementAssignment']);
        Route::get('/placement/results', [PlacementController::class, 'getLecturerPlacementResults']);
        Route::post('/questions/upload', [LecturerController::class, 'uploadQuestionsExcel']);

        Route::prefix('placement-management')->group(function () {
            Route::post('/questions', [App\Http\Controllers\Api\PlacementManagementController::class, 'storePlacementQuestion']);
            Route::get('/questions', [App\Http\Controllers\Api\PlacementManagementController::class, 'getPlacementQuestions']);
            Route::post('/upload', [App\Http\Controllers\Api\PlacementManagementController::class, 'uploadPlacementExcel']);
        });

    });

    Route::get('/materials/stream/{filename}', function ($filename) {
        $fullPath = storage_path('app/public/materials/' . $filename);

        if (!file_exists($fullPath)) {
            return response()->json(['message' => 'Berkas tidak ditemukan.'], 404);
        }

        // Bersihkan sisa output memory agar tidak tersedak saat transfer biner
        while (ob_get_level()) {
            ob_end_clean();
        }

        $content = file_get_contents($fullPath);

        return response($content, 200, [
            'Content-Type' => 'application/pdf',
            'Content-Length' => strlen($content),
            'Cache-Control' => 'no-cache, private',
        ]);
    });
});

/*
|--------------------------------------------------------------------------
| Jalur Penyelamat Berkas Besar (Anti-Connection-Closed Windows)
|--------------------------------------------------------------------------
*/
Route::get('/materials/download-stable/{filename}', function ($filename) {
    $fullPath = storage_path('app/public/materials/' . $filename);

    if (!file_exists($fullPath)) {
        return response()->json(['message' => 'Berkas tidak ditemukan.'], 404);
    }

    // MANDATORI: Hancurkan seluruh lapisan mangkok memori PHP di Windows
    while (ob_get_level()) {
        ob_end_clean();
    }

    $size = filesize($fullPath);

    // Kirim instruksi mentah ke hardware jaringan laptop
    header('Content-Type: application/pdf');
    header('Content-Length: ' . $size);
    header('Cache-Control: no-cache, private');
    header('Connection: keep-alive'); // Paksa Windows menjaga kabel koneksi tetap hidup!

    // Buka berkas secara biner dan potong menjadi kepingan kecil 64KB
    $file = fopen($fullPath, 'rb');
    while (!feof($file)) {
        echo fread($file, 65536); // Kirim per 64KB
        flush(); // Paksa Windows menyemburkannya langsung saat ini juga ke emulator
    }
    fclose($file);

    exit; // Matikan mesin skrip secara paksa agar tidak ada buffer tambahan dari Laravel
});

Route::get('/login', function () {
    return response()->json(['message' => 'Unauthenticated'], 401);
})->name('login');
