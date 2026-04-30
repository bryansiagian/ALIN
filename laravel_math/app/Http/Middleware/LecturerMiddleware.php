<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class LecturerMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Cek apakah user sudah login dan apakah rolenya 'lecturer' atau 'admin'
        if ($request->user() && ($request->user()->role === 'lecturer' || $request->user()->role === 'admin')) {
            return $next($request);
        }

        // Jika bukan lecturer, beri respon 403 Forbidden
        return response()->json([
            'message' => 'Akses ditolak. Hanya untuk Dosen atau Admin.'
        ], 403);
    }
}
