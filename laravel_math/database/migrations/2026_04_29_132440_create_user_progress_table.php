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
        Schema::create('user_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('topic_id')->constrained('topics')->onDelete('cascade');
            $table->integer('score_avg')->default(0); // Sesuai DBML
            $table->integer('time_spent_seconds')->default(0); // Sesuai DBML
            $table->enum('status', ['not_started', 'in_progress', 'completed'])->default('not_started'); // KOLOM YANG HILANG
            $table->timestamp('last_activity')->nullable();
            $table->timestamps();

            // Pastikan satu user hanya punya satu progress per topik
            $table->unique(['user_id', 'topic_id'], 'uq_user_topic_progress');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_progress');
    }
};
