<?php

namespace App\Livewire\Dosen;

use App\Models\QuestionBank;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithFileUploads;

class QuestionImport extends Component
{
    use WithFileUploads;

    public $placement_file;
    public $gamification_file;
    public $gamification_topic_id = '';

    public $placement_result = null;
    public $gamification_result = null;

    public function importPlacement()
    {
        $this->validate([
            'placement_file' => 'required|mimes:csv,txt|max:5120',
        ]);

        [$rows, $errors] = $this->parseCsv($this->placement_file->getRealPath(), 6);

        $inserted = 0;
        foreach ($rows as $i => $row) {
            [$questionText, $a, $b, $c, $d, $correct, $difficulty] = array_pad($row, 7, null);

            $correct = strtoupper(trim($correct ?? ''));
            $difficulty = strtolower(trim($difficulty ?? 'medium'));

            if (!$questionText || !$a || !$b || !$c || !$d || !in_array($correct, ['A','B','C','D'])) {
                $errors[] = "Baris " . ($i + 2) . ": data tidak lengkap atau correct_answer bukan A/B/C/D.";
                continue;
            }
            if (!in_array($difficulty, ['easy', 'medium', 'hard'])) {
                $difficulty = 'medium';
            }

            DB::table('placement_questions')->insert([
                'question_text' => trim($questionText),
                'options' => json_encode([
                    'A' => trim($a), 'B' => trim($b), 'C' => trim($c), 'D' => trim($d),
                ]),
                'correct_answer' => $correct,
                'difficulty' => $difficulty,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $inserted++;
        }

        $this->placement_result = ['inserted' => $inserted, 'errors' => $errors];
        $this->placement_file = null;
    }

    public function importGamification()
    {
        $this->validate([
            'gamification_file' => 'required|mimes:csv,txt|max:5120',
            'gamification_topic_id' => 'required|exists:topics,id',
        ]);

        [$rows, $errors] = $this->parseCsv($this->gamification_file->getRealPath(), 6);

        $inserted = 0;
        foreach ($rows as $i => $row) {
            [$questionText, $a, $b, $c, $d, $correct, $difficulty] = array_pad($row, 7, null);

            $correct = strtoupper(trim($correct ?? ''));
            $difficulty = strtolower(trim($difficulty ?? 'medium'));

            if (!$questionText || !$a || !$b || !$c || !$d || !in_array($correct, ['A','B','C','D'])) {
                $errors[] = "Baris " . ($i + 2) . ": data tidak lengkap atau correct_answer bukan A/B/C/D.";
                continue;
            }
            if (!in_array($difficulty, ['easy', 'medium', 'hard'])) {
                $difficulty = 'medium';
            }

            QuestionBank::create([
                'topic_id' => $this->gamification_topic_id,
                'question_text' => trim($questionText),
                'question_image' => null,
                'question_type' => 'multiple_choice',
                'difficulty' => $difficulty,
                'options' => [
                    ['key' => 'A', 'text' => trim($a), 'image' => null],
                    ['key' => 'B', 'text' => trim($b), 'image' => null],
                    ['key' => 'C', 'text' => trim($c), 'image' => null],
                    ['key' => 'D', 'text' => trim($d), 'image' => null],
                ],
                'correct_answer' => $correct,
                'is_quiz' => false,
                'is_placement' => false,
            ]);
            $inserted++;
        }

        $this->gamification_result = ['inserted' => $inserted, 'errors' => $errors];
        $this->gamification_file = null;
    }

    /**
     * Parse CSV: baris pertama dianggap header dan dilewati.
     * Return [rows_data, errors_awal]
     */
    private function parseCsv($path, $expectedMinCols)
    {
        $rows = [];
        $errors = [];
        $handle = fopen($path, 'r');
        $lineNum = 0;

        while (($data = fgetcsv($handle, 0, ',')) !== false) {
            $lineNum++;
            if ($lineNum === 1) continue; // skip header
            if (count(array_filter($data)) === 0) continue; // skip baris kosong
            $rows[] = $data;
        }
        fclose($handle);

        return [$rows, $errors];
    }

    public function render()
    {
        return view('livewire.dosen.question-import', [
            'topics' => \App\Models\Topic::orderBy('title')->get(),
        ])->layout('layouts.dosen');
    }
}
