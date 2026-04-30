<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Leaderboard;
use App\Models\Badge;
use App\Models\UserProgress;
use Illuminate\Http\Request;

class GamificationController extends Controller
{
    public function getLeaderboard()
    {
        return response()->json(
            Leaderboard::with('user:id,name,avatar')
                ->orderBy('points', 'desc')
                ->limit(10)
                ->get()
        );
    }

    public function getMyBadges(Request $request)
    {
        return response()->json($request->user()->badges);
    }

    public function updateProgress(Request $request)
    {
        $progress = UserProgress::updateOrCreate(
            ['user_id' => $request->user()->id, 'topic_id' => $request->topic_id],
            ['completion_percentage' => $request->percentage, 'average_score' => $request->score]
        );
        return response()->json($progress);
    }
}
