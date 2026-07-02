<div>
    <div class="mb-6">
        <button type="button" onclick="history.back()" class="text-sm text-slate-500 hover:text-slate-700">← Kembali</button>
        <h1 class="text-2xl font-semibold text-slate-900 mt-2">Edit Soal</h1>
    </div>

    @if (session('success'))
        <div class="mb-4 bg-emerald-50 text-emerald-700 text-sm px-4 py-2.5 rounded-lg border border-emerald-200">
            {{ session('success') }}
        </div>
    @endif

    <form wire:submit="save" class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
        <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">Pertanyaan</label>
            <textarea wire:model="question_text" rows="2" class="w-full rounded-lg border-slate-300 text-sm"></textarea>
            @error('question_text') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
        </div>

        <div>
            <label class="block text-sm font-medium text-slate-700 mb-1">Gambar Soal (opsional)</label>
            <input type="file" wire:model="image" accept="image/*" class="text-sm">
            @if ($image)
                <img src="{{ $image->temporaryUrl() }}" class="mt-2 h-24 rounded-lg border border-slate-200">
            @elseif ($existing_image)
                <div class="relative inline-block mt-2">
                    <img src="{{ $existing_image }}" class="h-24 rounded-lg border border-slate-200">
                    <button type="button" wire:click="removeImage" class="absolute -top-2 -right-2 bg-red-600 text-white rounded-full w-5 h-5 text-xs leading-none">×</button>
                </div>
            @endif
            @error('image') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
        </div>

        <div class="space-y-3">
            <label class="block text-sm font-medium text-slate-700">Opsi Jawaban</label>
            @foreach ($options as $oIndex => $option)
                <div class="flex gap-3 items-start bg-slate-50 rounded-lg p-3" wire:key="opt-{{ $oIndex }}">
                    <label class="flex items-center gap-2 pt-2">
                        <input type="radio" wire:model="correct_answer" value="{{ $option['key'] }}" class="text-indigo-600">
                        <span class="text-sm font-semibold text-slate-700 w-5">{{ $option['key'] }}</span>
                    </label>
                    <div class="flex-1 space-y-2">
                        <input type="text" wire:model="options.{{ $oIndex }}.text"
                            placeholder="Teks opsi {{ $option['key'] }}"
                            class="w-full rounded-lg border-slate-300 text-sm">
                        <input type="file" wire:model="options.{{ $oIndex }}.image" accept="image/*" class="text-xs">
                        @if ($option['image'])
                            <img src="{{ $option['image']->temporaryUrl() }}" class="h-16 rounded-lg border border-slate-200">
                        @elseif ($option['existing_image'])
                            <div class="relative inline-block">
                                <img src="{{ $option['existing_image'] }}" class="h-16 rounded-lg border border-slate-200">
                                <button type="button" wire:click="removeOptionImage({{ $oIndex }})" class="absolute -top-2 -right-2 bg-red-600 text-white rounded-full w-5 h-5 text-xs leading-none">×</button>
                            </div>
                        @endif
                    </div>
                </div>
            @endforeach
            <p class="text-xs text-slate-400">Pilih radio button di samping huruf untuk menandai jawaban benar.</p>
        </div>

        <div class="flex justify-end gap-3 pt-2">
            <button type="submit" class="px-5 py-2.5 text-sm bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium">
                <span wire:loading.remove wire:target="save">Simpan Perubahan</span>
                <span wire:loading wire:target="save">Menyimpan...</span>
            </button>
        </div>
    </form>
</div>
