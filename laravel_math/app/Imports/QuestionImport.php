<?php

namespace App\Imports;

use App\Models\QuestionBank;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings;
use Exception;

class QuestionImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    public function getCsvSettings(): array
    {
        return [
            'delimiter' => ','
        ];
    }

    public function model(array $row)
    {
        if (isset($row['topic_id']) && (int)$row['topic_id'] === 6) {
            throw new Exception("Import dibatalkan: Soal dengan topic_id 6 tidak diizinkan.");
        }

        if (!isset($row['question_text']) || empty($row['question_text'])) {
            return null;
        }

        $options = [];
        if (!empty($row['option_a'])) $options[] = ['label' => 'A', 'text' => (string)$row['option_a']];
        if (!empty($row['option_b'])) $options[] = ['label' => 'B', 'text' => (string)$row['option_b']];
        if (!empty($row['option_c'])) $options[] = ['label' => 'C', 'text' => (string)$row['option_c']];
        if (!empty($row['option_d'])) $options[] = ['label' => 'D', 'text' => (string)$row['option_d']];
        if (!empty($row['option_e'])) $options[] = ['label' => 'E', 'text' => (string)$row['option_e']];

        $rawAnswer = strtoupper($row['correct_answer'] ?? 'A');
        $cleanAnswer = preg_replace('/[^A-E]/', '', $rawAnswer);
        $finalAnswer = substr($cleanAnswer, 0, 1);

        if (empty($finalAnswer)) {
            $finalAnswer = 'A';
        }

        return new QuestionBank([
            'topic_id'       => $row['topic_id'] ?? 1,
            'question_text'  => $row['question_text'],
            'question_type'  => $row['question_type'] ?? 'multiple_choice',
            'difficulty'     => $row['difficulty'] ?? 'medium',
            'options'        => $options,
            'correct_answer' => $finalAnswer,
            'explanation'    => $row['explanation'] ?? null,
            'is_placement'   => false,
        ]);
    }
}
