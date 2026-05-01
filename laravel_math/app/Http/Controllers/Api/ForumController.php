<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ForumThread;
use App\Models\ForumReply;
use Illuminate\Http\Request;

class ForumController extends Controller
{
    // Ambil semua postingan (Timeline)
    public function getThreads()
    {
        $threads = ForumThread::with([
            // TAMBAHKAN 'email' di sini:
            'user:id,name,email,role,prodi,nim',
            'topic:id,title'
        ])
        ->withCount('replies')
        ->latest()
        ->get();

        return response()->json($threads);
    }

    // Buat postingan baru (Tweet)
    public function storeThread(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'body' => 'required|string', // Pastikan divalidasi
            'topic_id' => 'required'
        ]);

        $thread = ForumThread::create([
            'user_id' => $request->user()->id,
            'topic_id' => $request->topic_id,
            'title' => $request->title,
            'body' => $request->body, // <--- Gunakan 'body'
        ]);

        return response()->json($thread, 201);
    }

    // Lihat detail postingan + Balasannya
    public function getThreadDetail($id)
    {
        $thread = ForumThread::with(['user', 'replies.user'])->findOrFail($id);
        return response()->json($thread);
    }

    // Balas postingan
    public function storeReply(Request $request, $threadId)
    {
        $request->validate(['body' => 'required|string']);

        $reply = ForumReply::create([
            'thread_id' => $threadId,
            'user_id' => $request->user()->id,
            'body' => $request->body,
        ]);

        return response()->json($reply->load('user'), 201);
    }
}
