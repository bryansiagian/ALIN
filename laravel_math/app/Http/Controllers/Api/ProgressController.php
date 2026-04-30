<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserProgress;
use App\Models\UserStreak;
use App\Models\Topic;

class ProgressController extends Controller
{
    public function getAnalytics(Request $request)
    {
        $user = $request->user();

        $streak = UserStreak::where('user_id', $user->id)->first();
        $progress = UserProgress::with('topic')->where('user_id', $user->id)->get();

        $totalTopics = Topic::count();
        $completedTopics = UserProgress::where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();

        $overallPercentage = $totalTopics > 0 ? ($completedTopics / $totalTopics) * 100 : 0;

        return response()->json([
            'streak' => $streak,
            'overall_percentage' => round($overallPercentage),
            'total_topics' => $totalTopics,
            'completed_topics' => $completedTopics,
            'topic_analytics' => $progress
        ]);
    }
}
