<div class="min-h-screen flex items-center justify-center px-4"
    style="background-color:#F5F8FC; background-image: radial-gradient(#DCE3F0 1px, transparent 1px); background-size: 22px 22px;">
    <div class="w-full max-w-sm">
        <div class="flex items-center justify-center gap-2 mb-6">
            <span class="font-mono text-2xl text-[#2F6FED]">[</span>
            <span class="font-['Space_Grotesk'] text-lg font-bold text-[#101B33] tracking-tight">ALIN</span>
            <span class="font-mono text-2xl text-[#2F6FED]">]</span>
        </div>

        <div class="bg-white rounded-2xl shadow-sm shadow-blue-900/5 border border-[#DCE3F0] p-8">
            <h1 class="font-['Space_Grotesk'] text-xl font-bold text-[#101B33] mb-1">Portal Dosen</h1>
            <p class="text-sm text-[#435273] mb-6">Aljabar Linear — masuk untuk mengelola kelas Anda.</p>

            <form wire:submit="login" class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-[#435273] mb-1">Email</label>
                    <input type="email" wire:model="email"
                        class="w-full rounded-xl border-[#DCE3F0] focus:border-[#2F6FED] focus:ring-[#2F6FED] text-sm">
                    @error('email') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label class="block text-sm font-medium text-[#435273] mb-1">Password</label>
                    <input type="password" wire:model="password"
                        class="w-full rounded-xl border-[#DCE3F0] focus:border-[#2F6FED] focus:ring-[#2F6FED] text-sm">
                    @error('password') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>

                <button type="submit"
                    class="w-full bg-[#2F6FED] hover:bg-blue-700 text-white text-sm font-semibold py-2.5 rounded-xl shadow-sm shadow-blue-600/25 transition">
                    Masuk
                </button>
            </form>
        </div>
    </div>
</div>
