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
        Schema::create('exam_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained('assignments')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('submitted_at')->nullable(); // Sesuai DBML (sebelumnya finished_at)
            $table->timestamp('expired_at')->nullable();
            $table->integer('total_score')->nullable(); // Sesuai DBML (sebelumnya final_score)
            $table->enum('status', ['pending', 'ongoing', 'submitted', 'expired'])->default('pending');
            $table->boolean('is_locked')->default(false);
            $table->integer('violation_count')->default(0);
            $table->timestamps();

            // Index unik agar satu user hanya punya satu sesi per assignment
            $table->unique(['assignment_id', 'user_id'], 'uq_session_user');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exam_sessions');
    }
};
