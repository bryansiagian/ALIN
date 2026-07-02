<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Portal Dosen — ALIN</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
</head>
<body style="background-color:#F5F8FC;">
    <div class="flex min-h-screen" x-data="{ sidebarOpen: false }">

        {{-- Sidebar --}}
        <aside class="w-64 flex flex-col shrink-0 fixed inset-y-0 left-0 z-30 transition-transform lg:translate-x-0 lg:static"
            :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full'"
            style="background:#FFFFFF; border-right:1px solid #E3EBFA;">

            {{-- Logo --}}
            <div class="flex items-center gap-3 px-6 py-5" style="border-bottom:1px solid #E3EBFA;">
                <div class="w-10 h-10 rounded-[14px] flex items-center justify-center shrink-0"
                    style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 6px 14px -4px rgba(26,95,212,0.4);">
                    <span class="text-white text-lg font-bold">∑</span>
                </div>
                <div>
                    <p class="font-['Space_Grotesk'] text-base font-black tracking-wide"
                        style="background: linear-gradient(135deg, #1A40A8, #2D6EE8); -webkit-background-clip: text; background-clip: text; color: transparent;">
                        ALIN
                    </p>
                    <p class="text-[11px] font-medium" style="color:#7C8DB5;">Portal Dosen</p>
                </div>
            </div>

            {{-- Nav --}}
            <nav class="flex-1 px-3 py-5 space-y-1 text-sm overflow-y-auto">
                @php
                    $navItem = function ($route, $label, $icon, $active) {
                        return compact('route', 'label', 'icon', 'active');
                    };
                @endphp

                {{-- Dashboard --}}
                <a href="{{ route('dosen.dashboard') }}"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl font-medium transition-colors"
                    style="{{ request()->routeIs('dosen.dashboard')
                        ? 'background: linear-gradient(135deg, #4B8EFF, #1A5FD4); color:#fff; box-shadow: 0 6px 14px -6px rgba(26,95,212,0.5);'
                        : 'color:#435273;' }}"
                    onmouseover="if(!this.style.boxShadow) this.style.background='#F0F6FF'"
                    onmouseout="if(!'{{ request()->routeIs('dosen.dashboard') ? '1' : '' }}') this.style.background=''">
                    <svg class="w-[18px] h-[18px] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6A2.25 2.25 0 016 3.75h2.25A2.25 2.25 0 0110.5 6v2.25a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25V6zM3.75 15.75A2.25 2.25 0 016 13.5h2.25a2.25 2.25 0 012.25 2.25V18a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18v-2.25zM13.5 6a2.25 2.25 0 012.25-2.25H18A2.25 2.25 0 0120.25 6v2.25A2.25 2.25 0 0118 10.5h-2.25a2.25 2.25 0 01-2.25-2.25V6zM13.5 15.75a2.25 2.25 0 012.25-2.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-2.25A2.25 2.25 0 0113.5 18v-2.25z" />
                    </svg>
                    Dashboard
                </a>

                <p class="px-3 pt-4 pb-1 text-[10px] font-bold uppercase tracking-wider" style="color:#A9B6D6;">Konten</p>

                @foreach ([
                    ['route' => 'dosen.topics', 'label' => 'Topik', 'match' => 'dosen.topics', 'icon' => 'M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z'],
                    ['route' => 'dosen.materials', 'label' => 'Materi', 'match' => 'dosen.materials', 'icon' => 'M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25'],
                    ['route' => 'dosen.quizzes', 'label' => 'Kuis', 'match' => 'dosen.quizzes*', 'icon' => 'M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z'],
                ] as $item)
                    <a href="{{ route($item['route']) }}"
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl font-medium transition-colors"
                        style="{{ request()->routeIs($item['match'])
                            ? 'background: linear-gradient(135deg, #4B8EFF, #1A5FD4); color:#fff; box-shadow: 0 6px 14px -6px rgba(26,95,212,0.5);'
                            : 'color:#435273;' }}">
                        <svg class="w-[18px] h-[18px] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="{{ $item['icon'] }}" />
                        </svg>
                        {{ $item['label'] }}
                    </a>
                @endforeach

                <p class="px-3 pt-4 pb-1 text-[10px] font-bold uppercase tracking-wider" style="color:#A9B6D6;">Penilaian</p>

                @foreach ([
                    ['route' => 'dosen.placement.results', 'label' => 'Hasil Placement', 'match' => 'dosen.placement.results', 'icon' => 'M9 17.25v1.007a3 3 0 01-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0115 18.257V17.25m6-12V15a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 15V5.25m18 0A2.25 2.25 0 0018.75 3H5.25A2.25 2.25 0 003 5.25m18 0V12a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 12V5.25'],
                    ['route' => 'dosen.placement-questions', 'label' => 'Soal Placement', 'match' => 'dosen.placement-questions', 'icon' => 'M8.25 6.75h12M8.25 12h12m-12 5.25h12M3.75 6.75h.007v.008H3.75V6.75zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zM3.75 12h.007v.008H3.75V12zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm-.375 5.25h.007v.008H3.75v-.008zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z'],
                    ['route' => 'dosen.gamification-questions', 'label' => 'Soal Latihan', 'match' => 'dosen.gamification-questions', 'icon' => 'M11.25 4.5l7.5 7.5-7.5 7.5m-6-15l7.5 7.5-7.5 7.5'],
                    ['route' => 'dosen.questions.import', 'label' => 'Upload Soal (CSV)', 'match' => 'dosen.questions.import', 'icon' => 'M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3'],
                ] as $item)
                    <a href="{{ route($item['route']) }}"
                        class="flex items-center gap-3 px-3 py-2.5 rounded-xl font-medium transition-colors"
                        style="{{ request()->routeIs($item['match'])
                            ? 'background: linear-gradient(135deg, #4B8EFF, #1A5FD4); color:#fff; box-shadow: 0 6px 14px -6px rgba(26,95,212,0.5);'
                            : 'color:#435273;' }}">
                        <svg class="w-[18px] h-[18px] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="{{ $item['icon'] }}" />
                        </svg>
                        {{ $item['label'] }}
                    </a>
                @endforeach

                <p class="px-3 pt-4 pb-1 text-[10px] font-bold uppercase tracking-wider" style="color:#A9B6D6;">Mahasiswa</p>

                <a href="{{ route('dosen.students') }}"
                    class="flex items-center gap-3 px-3 py-2.5 rounded-xl font-medium transition-colors"
                    style="{{ request()->routeIs('dosen.students*')
                        ? 'background: linear-gradient(135deg, #4B8EFF, #1A5FD4); color:#fff; box-shadow: 0 6px 14px -6px rgba(26,95,212,0.5);'
                        : 'color:#435273;' }}">
                    <svg class="w-[18px] h-[18px] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                    </svg>
                    Mahasiswa
                </a>
            </nav>

            {{-- User & Logout --}}
            <div class="px-3 py-4" style="border-top:1px solid #E3EBFA;">
                <form action="{{ route('dosen.logout') }}" method="POST">
                    @csrf
                    <button type="submit"
                        class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors"
                        style="color:#E53935;"
                        onmouseover="this.style.background='#FFEBEE'"
                        onmouseout="this.style.background=''">
                        <svg class="w-[18px] h-[18px] shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0110.5 3h6a2.25 2.25 0 012.25 2.25v13.5A2.25 2.25 0 0116.5 21h-6a2.25 2.25 0 01-2.25-2.25V15m-3 0l-3-3m0 0l3-3m-3 3H15" />
                        </svg>
                        Keluar
                    </button>
                </form>
            </div>
        </aside>

        {{-- Mobile overlay --}}
        <div x-show="sidebarOpen" x-cloak @click="sidebarOpen = false"
            class="fixed inset-0 bg-black/30 z-20 lg:hidden"></div>

        {{-- Main content --}}
        <div class="flex-1 flex flex-col min-w-0 lg:ml-0">
            {{-- Topbar (mobile only) --}}
            <header class="flex items-center gap-3 px-4 py-3 lg:hidden"
                style="background:#FFFFFF; border-bottom:1px solid #E3EBFA;">
                <button @click="sidebarOpen = true" style="color:#0F2D6B;">
                    <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                    </svg>
                </button>
                <span class="font-['Space_Grotesk'] font-black text-sm"
                    style="background: linear-gradient(135deg, #1A40A8, #2D6EE8); -webkit-background-clip: text; background-clip: text; color: transparent;">
                    ALIN
                </span>
            </header>

            <main class="flex-1 p-6 lg:p-8" style="background-color:#F5F8FC; background-image: radial-gradient(#E3EBFA 1px, transparent 1px); background-size: 24px 24px;">
                {{ $slot }}
            </main>
        </div>
    </div>
    @livewireScripts
</body>
</html>
