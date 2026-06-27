<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Mematikan foreign key agar truncate bisa jalan
        \Illuminate\Support\Facades\DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Bersihkan tabel
        \App\Models\Topic::truncate();

        // Data Master
        $topics = [
            ['id' => 1, 'title' => 'SPL', 'slug' => 'spl', 'order_index' => 1, 'is_active' => true],
            ['id' => 2, 'title' => 'Matriks', 'slug' => 'matriks', 'order_index' => 2, 'is_active' => true],
            ['id' => 3, 'title' => 'Operasi Baris Elementer', 'slug' => 'obe', 'order_index' => 3, 'is_active' => true],
            ['id' => 4, 'title' => 'Eliminasi Gauss', 'slug' => 'eliminasi-gauss', 'order_index' => 4, 'is_active' => true],
            ['id' => 5, 'title' => 'Invers Matriks', 'slug' => 'invers-matriks', 'order_index' => 5, 'is_active' => true],
            ['id' => 6, 'title' => 'Placement Test', 'slug' => 'placement-test', 'order_index' => 6, 'is_active' => true],
            ['id' => 7, 'title' => 'Determinan', 'slug' => 'determinan', 'order_index' => 7, 'is_active' => true],
            ['id' => 8, 'title' => 'Transformasi Linear', 'slug' => 'transformasi-linear', 'order_index' => 8, 'is_active' => true],
            ['id' => 9, 'title' => 'Eigenvalue & Eigenvector', 'slug' => 'eigenvalue-eigenvector', 'order_index' => 9, 'is_active' => true],
            ['id' => 10, 'title' => 'Diagonalisasi', 'slug' => 'diagonalisasi', 'order_index' => 10, 'is_active' => true],
        ];

        foreach ($topics as $topic) {
            \App\Models\Topic::create($topic);
        }

        \Illuminate\Support\Facades\DB::statement('SET FOREIGN_KEY_CHECKS=1;');
    }
}
