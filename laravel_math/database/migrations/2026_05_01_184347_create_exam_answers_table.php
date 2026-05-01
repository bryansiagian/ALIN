<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exam_answers', function (Blueprint $table) {
            $table->id();
            // Menghubungkan ke sesi ujian (Siapa yang mengerjakan)
            $table->foreignId('exam_session_id')->constrained('exam_sessions')->onDelete('cascade');
            // Menghubungkan ke bank soal (Soal nomor berapa)
            $table->foreignId('question_id')->constrained('question_banks')->onDelete('cascade');
            // Jawaban yang dipilih mahasiswa (A, B, C, atau D)
            $table->text('user_answer')->nullable();
            // Flag koreksi otomatis
            $table->boolean('is_correct')->nullable();
            // Skor poin untuk soal ini (misal 1 jika benar, 0 jika salah)
            $table->integer('score')->default(0);
            $table->timestamps();

            // Index unik agar satu soal hanya punya satu jawaban dalam satu sesi
            $table->unique(['exam_session_id', 'question_id'], 'uq_session_question');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exam_answers');
    }
};
