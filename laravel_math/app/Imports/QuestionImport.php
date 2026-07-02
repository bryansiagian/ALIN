<?php

namespace App\Imports;

use App\Models\QuestionBank;
use Maatwebsite\Excel\Concerns\ToModel;
use Maatwebsite\Excel\Concerns\WithHeadingRow;
use Maatwebsite\Excel\Concerns\WithCustomCsvSettings;
use Exception;

class QuestionImport implements ToModel, WithHeadingRow, WithCustomCsvSettings
{
    protected $overrideTopicId;

    public function __construct($overrideTopicId = null)
    {
        $this->overrideTopicId = $overrideTopicId;
    }

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
        if (!empty($row['option_a'])) $options[] = ['key' => 'A', 'text' => (string)$row['option_a'], 'image' => null];
        if (!empty($row['option_b'])) $options[] = ['key' => 'B', 'text' => (string)$row['option_b'], 'image' => null];
        if (!empty($row['option_c'])) $options[] = ['key' => 'C', 'text' => (string)$row['option_c'], 'image' => null];
        if (!empty($row['option_d'])) $options[] = ['key' => 'D', 'text' => (string)$row['option_d'], 'image' => null];

        $rawAnswer = strtoupper($row['correct_answer'] ?? 'A');
        $cleanAnswer = preg_replace('/[^A-D]/', '', $rawAnswer);
        $finalAnswer = substr($cleanAnswer, 0, 1) ?: 'A';

        return new QuestionBank([
            'topic_id'       => $this->overrideTopicId ?? ($row['topic_id'] ?? 1),
            'question_text'  => $row['question_text'],
            'question_type'  => $row['question_type'] ?? 'multiple_choice',
            'difficulty'     => $row['difficulty'] ?? 'medium',
            'options'        => $options,
            'correct_answer' => $finalAnswer,
            'explanation'    => $row['explanation'] ?? null,
            'is_quiz'        => false,
            'is_placement'   => false,
        ]);
    }
}
