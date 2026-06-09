<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lecturer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('topic_id')->constrained('topics')->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->timestamp('start_time')->nullable();
            $table->timestamp('deadline'); 
            $table->integer('duration_minutes');
            $table->integer('question_count');
            $table->boolean('is_safe_exam')->default(false);
            $table->boolean('allow_reattempt')->default(false); // Bisa mengulang atau tidak
            $table->integer('attempt_limit')->default(1);       // Batas maksimal percobaan
            $table->boolean('show_results')->default(true);
            $table->enum('status', ['draft', 'published', 'closed'])->default('draft');
            $table->boolean('is_placement')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('assignments');
    }
};
