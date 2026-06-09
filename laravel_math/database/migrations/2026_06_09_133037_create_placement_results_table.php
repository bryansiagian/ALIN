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
        Schema::create('placement_results', function (Blueprint $table) {
            $table->id();
            // Menghubungkan ke tabel users, jika user dihapus, data ini ikut terhapus
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->integer('score'); // Menyimpan skor 0 - 100
            $table->integer('unlocked_level'); // Menyimpan level maks yang terbuka (1 - 50)
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('placement_results');
    }
};
