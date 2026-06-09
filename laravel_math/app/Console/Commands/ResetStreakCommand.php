<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\UserStreak;
use Carbon\Carbon;

class ResetStreakCommand extends Command
{
    // Nama tombol saklar untuk menjalankan satpam ini
    protected $signature = 'streak:reset';
    protected $description = 'Mereset streak mahasiswa yang tidak belajar kemarin ke 0';

    public function handle()
    {
        $kemarin = \Carbon\Carbon::yesterday()->toDateString();

        // Gunakan current_streak, bukan streak_count!
        $bolos = \App\Models\UserStreak::where('current_streak', '>', 0)
            ->where('last_active_date', '<', $kemarin)
            ->update(['current_streak' => 0]);

        $this->info("Satpam Malam: Berhasil mereset {$bolos} streak mahasiswa yang bolos!");
    }
}
