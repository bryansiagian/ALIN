<div>
    {{-- Header --}}
    <div class="mb-6">
        <button type="button" onclick="history.back()"
            class="inline-flex items-center gap-1 text-sm font-medium transition-colors" style="color:#7C8DB5;"
            onmouseover="this.style.color='#2F6FED'" onmouseout="this.style.color='#7C8DB5'">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Kembali
        </button>
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold mt-2" style="color:#0F2D6B;">Edit Soal</h1>
    </div>

    {{-- Flash message --}}
    @if (session('success'))
        <div class="flex items-center gap-2 mb-4 text-sm px-4 py-2.5 rounded-xl"
            style="background:#ECFDF5; border:1px solid #A7F3D0; color:#047857;">
            <svg class="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            {{ session('success') }}
        </div>
    @endif

    <form wire:submit="save" class="bg-white rounded-2xl p-6 space-y-4"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">

        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Pertanyaan</label>
            <textarea wire:model="question_text" rows="2"
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:{{ $errors->has('question_text') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;"></textarea>
            @error('question_text') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
        </div>

        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Gambar Soal (opsional)</label>
            <div class="rounded-xl border border-dashed px-3.5 py-3" style="background:#F0F6FF; border-color:#D0E2FF;">
                <input type="file" wire:model="image" accept="image/*" class="w-full text-xs" style="color:#435273;">
            </div>
            @if ($image)
                <img src="{{ $image->temporaryUrl() }}" class="mt-2 h-24 rounded-xl" style="border:1px solid #E3EBFA;">
            @elseif ($existing_image)
                <div class="relative inline-block mt-2">
                    <img src="{{ $existing_image }}" class="h-24 rounded-xl" style="border:1px solid #E3EBFA;">
                    <button type="button" wire:click="removeImage"
                        class="absolute -top-2 -right-2 text-white rounded-full w-5 h-5 text-xs leading-none flex items-center justify-center"
                        style="background:#E53935;">×</button>
                </div>
            @endif
            @error('image') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
        </div>

        <div class="space-y-3">
            <label class="block text-xs font-semibold" style="color:#0F2D6B;">Opsi Jawaban</label>
            @foreach ($options as $oIndex => $option)
                <div class="flex gap-3 items-start rounded-xl p-3" wire:key="opt-{{ $oIndex }}"
                    style="background:{{ $correct_answer === $option['key'] ? '#F0F6FF' : '#F5F8FC' }}; border:1px solid {{ $correct_answer === $option['key'] ? '#D0E2FF' : '#F0F4FC' }};">
                    <label class="flex items-center gap-2 pt-2">
                        <input type="radio"
                            wire:model="correct_answer"
                            value="{{ $option['key'] }}"
                            class="w-4 h-4" style="accent-color:#2F6FED;">
                        <span class="text-sm font-bold w-5" style="color:#0F2D6B;">{{ $option['key'] }}</span>
                    </label>
                    <div class="flex-1 space-y-2">
                        <input type="text"
                            wire:model="options.{{ $oIndex }}.text"
                            placeholder="Teks opsi {{ $option['key'] }}"
                            class="w-full rounded-lg border pl-3 pr-3 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#FFFFFF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                        <input type="file"
                            wire:model="options.{{ $oIndex }}.image"
                            accept="image/*" class="text-xs" style="color:#7C8DB5;">
                        @if ($option['image'])
                            <img src="{{ $option['image']->temporaryUrl() }}" class="h-16 rounded-lg" style="border:1px solid #E3EBFA;">
                        @elseif ($option['existing_image'])
                            <div class="relative inline-block">
                                <img src="{{ $option['existing_image'] }}" class="h-16 rounded-lg" style="border:1px solid #E3EBFA;">
                                <button type="button" wire:click="removeOptionImage({{ $oIndex }})"
                                    class="absolute -top-2 -right-2 text-white rounded-full w-5 h-5 text-xs leading-none flex items-center justify-center"
                                    style="background:#E53935;">×</button>
                            </div>
                        @endif
                    </div>
                </div>
            @endforeach
            <p class="text-xs" style="color:#A9B6D6;">Pilih radio button di samping huruf untuk menandai jawaban benar.</p>
        </div>

        <div class="flex justify-end gap-2 pt-2">
            <button type="submit"
                class="px-5 py-2.5 text-sm font-semibold text-white rounded-xl"
                style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
                <span wire:loading.remove wire:target="save">Simpan Perubahan</span>
                <span wire:loading wire:target="save">Menyimpan...</span>
            </button>
        </div>
    </form>
</div>