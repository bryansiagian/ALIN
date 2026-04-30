<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Topic;
use App\Models\Formula;
use Illuminate\Http\Request;

class ContentController extends Controller
{
    public function getTopics()
    {
        // PERBAIKAN: Gunakan order_index sesuai DBML, bukan order_priority
        return response()->json(
            Topic::withCount('materials')
                ->where('is_active', true)
                ->orderBy('order_index', 'asc')
                ->get()
        );
    }

    public function getMaterials($topicId)
    {
        // Memuat topik beserta materi di dalamnya
        $topic = Topic::with(['materials' => function($query) {
            $query->orderBy('order_index', 'asc');
        }])->findOrFail($topicId);

        return response()->json($topic);
    }

    public function getFormulas()
    {
        return response()->json(Formula::with('topic')->get());
    }

    public function toggleFavoriteFormula(Request $request, $id)
    {
        $user = $request->user();
        $user->favoriteFormulas()->toggle($id);
        return response()->json(['message' => 'Favorite updated']);
    }
}
