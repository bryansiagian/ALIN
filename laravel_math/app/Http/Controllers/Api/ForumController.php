<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ForumThread;
use App\Models\ForumReply;
use Illuminate\Http\Request;

class ForumController extends Controller
{
    public function getThreads()
    {
        return response()->json(ForumThread::with('user:id,name', 'topic')->latest()->get());
    }

    public function storeThread(Request $request)
    {
        $request->validate(['title' => 'required', 'content' => 'required', 'topic_id' => 'required']);

        $thread = ForumThread::create([
            'user_id' => $request->user()->id,
            'topic_id' => $request->topic_id,
            'title' => $request->title,
            'content' => $request->content,
        ]);

        return response()->json($thread, 201);
    }

    public function getThreadDetail($id)
    {
        return response()->json(ForumThread::with(['user', 'replies.user', 'replies.children.user'])->findOrFail($id));
    }

    public function storeReply(Request $request, $threadId)
    {
        $reply = ForumReply::create([
            'thread_id' => $threadId,
            'user_id' => $request->user()->id,
            'parent_reply_id' => $request->parent_reply_id,
            'content' => $request->content,
        ]);

        return response()->json($reply);
    }
}
