<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlacementManagementController extends Controller
{
    // Fungsi untuk menambah soal placement secara manual
    public function storePlacementQuestion(Request $request)
    {
        $validated = $request->validate([
            'question_text'  => 'required|string',
            'options'        => 'required|array', // Kirim sebagai array ["A", "B", "C", "D"]
            'correct_answer' => 'required|string',
            'difficulty'     => 'required|in:easy,medium,hard',
        ]);

        // ID tidak perlu lagi, karena otomatis masuk ke tabel soal placement
        DB::table('placement_questions')->insert([
            'question_text'  => $validated['question_text'],
            'options'        => json_encode($validated['options']),
            'correct_answer' => $validated['correct_answer'],
            'difficulty'     => $validated['difficulty'],
            'created_at'     => now(),
            'updated_at'     => now(),
        ]);

        return response()->json(['message' => 'Soal Placement masuk laci aman!'], 201);
    }

    // Fungsi untuk melihat semua soal placement
    public function getPlacementQuestions()
    {
        $questions = DB::table('placement_questions')->get();
        return response()->json($questions);
    }

    public function uploadPlacementExcel(Request $request)
    {
        // Cek apakah file benar-benar ada
        if (!$request->hasFile('file')) {
            return response()->json(['status' => 'error', 'message' => 'File tidak ditemukan!'], 400);
        }

        try {
            \Maatwebsite\Excel\Facades\Excel::import(new \App\Imports\PlacementImport, $request->file('file'));
            return response()->json(['status' => 'success', 'message' => 'Soal Placement berhasil diupload!'], 200);
        } catch (\Exception $e) {
            // KIRIM ERROR KE LOG SUPAYA BISA DIBACA
            \Illuminate\Support\Facades\Log::error('Gagal Import Placement: ' . $e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Error: ' . $e->getMessage()], 500);
        }
    }
}
