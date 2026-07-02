<div>
    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-slate-900">Upload Soal Massal (CSV)</h1>
        <p class="text-slate-500 text-sm mt-1">Import banyak soal sekaligus untuk Placement Test dan soal Latihan (Gamifikasi).</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {{-- Placement Test --}}
        <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
            <div>
                <h2 class="font-semibold text-slate-900">Soal Placement Test</h2>
                <p class="text-xs text-slate-500 mt-1">
                    Format kolom CSV (baris pertama = header, dilewati):<br>
                    <code class="bg-slate-100 px-1.5 py-0.5 rounded text-[11px]">question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs text-slate-400 mt-1">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard</p>
            </div>

            <form wire:submit="importPlacement" class="space-y-3">
                <input type="file" wire:model="placement_file" accept=".csv,.txt" class="text-sm">
                @error('placement_file') <p class="text-xs text-red-600">{{ $message }}</p> @enderror

                <button type="submit"
                    class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg"
                    wire:loading.attr="disabled" wire:target="importPlacement">
                    <span wire:loading.remove wire:target="importPlacement">Upload & Import</span>
                    <span wire:loading wire:target="importPlacement">Memproses...</span>
                </button>
            </form>

            @if ($placement_result)
                <div class="mt-3 text-sm">
                    <p class="text-emerald-700 font-medium">{{ $placement_result['inserted'] }} soal berhasil diimport.</p>
                    @if (count($placement_result['errors']))
                        <div class="mt-2 bg-red-50 border border-red-200 rounded-lg p-3 max-h-40 overflow-y-auto">
                            @foreach ($placement_result['errors'] as $err)
                                <p class="text-xs text-red-600">{{ $err }}</p>
                            @endforeach
                        </div>
                    @endif
                </div>
            @endif
        </div>

        {{-- Gamifikasi --}}
        <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
            <div>
                <h2 class="font-semibold text-slate-900">Soal Latihan (Gamifikasi / Level)</h2>
                <p class="text-xs text-slate-500 mt-1">
                    Format kolom CSV (baris pertama = header, dilewati):<br>
                    <code class="bg-slate-100 px-1.5 py-0.5 rounded text-[11px]">question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs text-slate-400 mt-1">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard</p>
            </div>

            <form wire:submit="importGamification" class="space-y-3">
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Topik</label>
                    <select wire:model="gamification_topic_id" class="w-full rounded-lg border-slate-300 text-sm">
                        <option value="">-- Pilih Topik --</option>
                        @foreach ($topics as $topic)
                            <option value="{{ $topic->id }}">{{ $topic->title }}</option>
                        @endforeach
                    </select>
                    @error('gamification_topic_id') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>

                <input type="file" wire:model="gamification_file" accept=".csv,.txt" class="text-sm">
                @error('gamification_file') <p class="text-xs text-red-600">{{ $message }}</p> @enderror

                <button type="submit"
                    class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg"
                    wire:loading.attr="disabled" wire:target="importGamification">
                    <span wire:loading.remove wire:target="importGamification">Upload & Import</span>
                    <span wire:loading wire:target="importGamification">Memproses...</span>
                </button>
            </form>

            @if ($gamification_result)
                <div class="mt-3 text-sm">
                    <p class="text-emerald-700 font-medium">{{ $gamification_result['inserted'] }} soal berhasil diimport.</p>
                    @if (count($gamification_result['errors']))
                        <div class="mt-2 bg-red-50 border border-red-200 rounded-lg p-3 max-h-40 overflow-y-auto">
                            @foreach ($gamification_result['errors'] as $err)
                                <p class="text-xs text-red-600">{{ $err }}</p>
                            @endforeach
                        </div>
                    @endif
                </div>
            @endif
        </div>

    </div>
</div>
