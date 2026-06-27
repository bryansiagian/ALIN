<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('placement_questions', function (Blueprint $table) {
            $table->id();
            $table->text('question_text');
            $table->json('options'); // Untuk menyimpan pilihan A, B, C, D, E
            $table->string('correct_answer');
            $table->string('difficulty')->default('medium'); // easy, medium, hard
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('placement_questions');
    }
};
