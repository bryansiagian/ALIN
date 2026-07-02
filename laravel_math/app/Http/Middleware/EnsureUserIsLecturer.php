<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsLecturer
{
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || $request->user()->role !== 'lecturer') {
            auth()->logout();
            return redirect()->route('dosen.login')->withErrors([
                'email' => 'Akun ini bukan akun dosen.',
            ]);
        }

        return $next($request);
    }
}
