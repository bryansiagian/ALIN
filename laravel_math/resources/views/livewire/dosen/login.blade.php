<div class="min-h-screen flex items-center justify-center px-4 py-10 relative overflow-hidden"
    style="background: linear-gradient(135deg, #EEF4FF 0%, #DCEAFF 35%, #B8D4FF 70%, #8AB8FF 100%);">

    <div class="w-full max-w-sm relative"
        x-data="{ show: false, mounted: false }"
        x-init="setTimeout(() => mounted = true, 50)">

        <div class="transition-all duration-700 ease-out"
            :class="mounted ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-3'">

            {{-- Logo --}}
            <div class="flex flex-col items-center mb-8">
                <div class="w-16 h-16 rounded-[20px] flex items-center justify-center mb-4"
                    style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 20px -4px rgba(26,95,212,0.4);">
                    <span class="text-white text-3xl font-bold">∑</span>
                </div>
                <h1 class="font-['Space_Grotesk'] text-2xl font-black tracking-wide"
                    style="background: linear-gradient(135deg, #1A40A8, #2D6EE8); -webkit-background-clip: text; background-clip: text; color: transparent;">
                    ALIN
                </h1>
                <p class="text-xs font-medium mt-1" style="color: rgba(26,95,212,0.75);">
                    Aplikasi Belajar Aljabar Linear
                </p>
            </div>

            {{-- Card --}}
            <div class="bg-white/90 backdrop-blur-sm rounded-[28px] p-7"
                style="box-shadow: 0 20px 40px -8px rgba(75,142,255,0.22), 0 -2px 8px rgba(255,255,255,0.9);">

                <h2 class="text-xl font-extrabold" style="color:#0F2D6B;">Selamat Datang 👋</h2>
                <p class="text-sm text-gray-500 mt-0.5 mb-6">Masuk untuk mengelola kelas Anda</p>

                {{-- General auth error (mis. kredensial salah) --}}
                @if (session('error'))
                    <div class="flex items-center gap-2 rounded-xl px-3.5 py-2.5 mb-5"
                        style="background:#FFEBEE; border:1px solid #FFCDD2;">
                        <svg class="w-4 h-4 shrink-0" style="color:#E53935" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
                        </svg>
                        <p class="text-xs" style="color:#B71C1C;">{{ session('error') }}</p>
                    </div>
                @endif

                <form wire:submit="login" class="space-y-4">
                    {{-- Email --}}
                    <div>
                        <label for="email" class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Email</label>
                        <div class="relative">
                            <svg class="w-4.5 h-4.5 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" style="color:#4B8EFF" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0-.414.336-.75.75-.75h18c.414 0 .75.336.75.75v10.5a.75.75 0 01-.75.75h-18a.75.75 0 01-.75-.75V6.75z" />
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.5 7l9.05 6.34a.75.75 0 00.9 0L21.5 7" />
                            </svg>
                            <input id="email" type="email" wire:model="email" autocomplete="email" autofocus
                                placeholder="contoh@email.com"
                                class="w-full rounded-xl border pl-10 pr-3.5 py-3 text-sm font-medium placeholder:text-gray-400 placeholder:font-normal transition-colors focus:outline-none focus:ring-2"
                                style="background:#F0F6FF; border-color:{{ $errors->has('email') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                        </div>
                        @error('email')
                            <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p>
                        @enderror
                    </div>

                    {{-- Password --}}
                    <div>
                        <label for="password" class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Password</label>
                        <div class="relative">
                            <svg class="w-4.5 h-4.5 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" style="color:#4B8EFF" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a1.5 1.5 0 001.5-1.5v-8.25a1.5 1.5 0 00-1.5-1.5H6.75a1.5 1.5 0 00-1.5 1.5v8.25a1.5 1.5 0 001.5 1.5z" />
                            </svg>
                            <input :type="show ? 'text' : 'password'" id="password" wire:model="password" autocomplete="current-password"
                                placeholder="Masukkan password"
                                class="w-full rounded-xl border pl-10 pr-10 py-3 text-sm font-medium placeholder:text-gray-400 placeholder:font-normal transition-colors focus:outline-none focus:ring-2"
                                style="background:#F0F6FF; border-color:{{ $errors->has('password') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                            <button type="button" @click="show = !show"
                                class="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-[#4B8EFF] transition-colors">
                                <svg x-show="!show" class="w-4.5 h-4.5" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z" />
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                </svg>
                                <svg x-show="show" x-cloak class="w-4.5 h-4.5" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12c1.292 4.338 5.31 7.5 10.066 7.5.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88" />
                                </svg>
                            </button>
                        </div>
                        @error('password')
                            <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p>
                        @enderror
                    </div>

                    {{-- Submit --}}
                    <button type="submit" wire:loading.attr="disabled" wire:target="login"
                        class="w-full rounded-xl py-3.5 text-sm font-bold text-white mt-2 flex items-center justify-center gap-2 transition-opacity disabled:opacity-70"
                        style="background: linear-gradient(90deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 20px -6px rgba(26,95,212,0.5);">
                        <svg wire:loading wire:target="login" class="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-90" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
                        </svg>
                        <span wire:loading.remove wire:target="login">Masuk</span>
                        <span wire:loading wire:target="login">Memproses...</span>
                    </button>
                </form>
            </div>

            {{-- Footer --}}
            <p class="text-center text-xs mt-6" style="color: rgba(26,95,212,0.5);">
                © {{ date('Y') }} ALIN — Aljabar Linear
            </p>
        </div>
    </div>
</div>
