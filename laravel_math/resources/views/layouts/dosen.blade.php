<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Portal Dosen — ALIN</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
</head>
<body class="bg-slate-50">
    <div class="flex min-h-screen">
        <aside class="w-64 bg-slate-900 text-slate-200 flex flex-col">
            <div class="px-6 py-5 border-b border-slate-800">
                <p class="font-semibold text-white">ALIN</p>
                <p class="text-xs text-slate-400">Portal Dosen</p>
            </div>
            <nav class="flex-1 px-3 py-4 space-y-1 text-sm">
                <a href="{{ route('dosen.dashboard') }}" class="block px-3 py-2 rounded-lg hover:bg-slate-800">Dashboard</a>
                <a href="{{ route('dosen.topics') }}" class="block px-3 py-2 rounded-lg hover:bg-slate-800 {{ request()->routeIs('dosen.topics') ? 'bg-slate-800 text-white' : '' }}">Topik</a>
                {{-- menu lain nyusul: Topik, Bank Soal, Kuis, Placement Test, Mahasiswa --}}
            </nav>
            <form action="{{ route('dosen.logout') }}" method="POST" class="px-3 py-4 border-t border-slate-800">
                @csrf
                <button class="w-full text-left text-sm text-slate-400 hover:text-white px-3 py-2">Keluar</button>
            </form>
        </aside>
        <main class="flex-1 p-8">
            {{ $slot }}
        </main>
    </div>
    @livewireScripts
</body>
</html>
