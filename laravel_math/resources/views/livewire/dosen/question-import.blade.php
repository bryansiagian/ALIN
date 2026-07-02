<div>
    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-slate-900">Upload Soal Massal</h1>
        <p class="text-slate-500 text-sm mt-1">Import banyak soal sekaligus untuk Placement Test dan soal Latihan (Gamifikasi). Mendukung format CSV dan Excel (.xlsx).</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {{-- Placement Test --}}
        <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
            <div>
                <h2 class="font-semibold text-slate-900">Soal Placement Test</h2>
                <p class="text-xs text-slate-500 mt-1">
                    Format kolom (baris pertama = header):<br>
                    <code class="bg-slate-100 px-1.5 py-0.5 rounded text-[11px]">question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs text-slate-400 mt-1">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard</p>
            </div>

            <form wire:submit="importPlacement" class="space-y-3">
                <input type="file" wire:model="placement_file" accept=".csv,.txt,.xlsx,.xls" class="text-sm">
                @error('placement_file') <p class="text-xs text-red-600">{{ $message }}</p> @enderror

                <button type="submit"
                    class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg"
                    wire:loading.attr="disabled" wire:target="importPlacement">
                    <span wire:loading.remove wire:target="importPlacement">Upload & Import</span>
                    <span wire:loading wire:target="importPlacement">Memproses...</span>
                </button>
            </form>

            @if ($placement_message)
                <div class="mt-3 text-sm {{ $placement_message['type'] === 'success' ? 'text-emerald-700' : 'text-red-600' }}">
                    {{ $placement_message['text'] }}
                </div>
            @endif
        </div>

        {{-- Gamifikasi --}}
        <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
            <div>
                <h2 class="font-semibold text-slate-900">Soal Latihan (Gamifikasi / Level)</h2>
                <p class="text-xs text-slate-500 mt-1">
                    Format kolom (baris pertama = header):<br>
                    <code class="bg-slate-100 px-1.5 py-0.5 rounded text-[11px]">topic_id,question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs text-slate-400 mt-1">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard &middot; topic_id boleh berbeda-beda tiap baris</p>
            </div>

            <form wire:submit="importGamification" class="space-y-3">
                <input type="file" wire:model="gamification_file" accept=".csv,.txt,.xlsx,.xls" class="text-sm">
                @error('gamification_file') <p class="text-xs text-red-600">{{ $message }}</p> @enderror

                <button type="submit"
                    class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg"
                    wire:loading.attr="disabled" wire:target="importGamification">
                    <span wire:loading.remove wire:target="importGamification">Upload & Import</span>
                    <span wire:loading wire:target="importGamification">Memproses...</span>
                </button>
            </form>

            @if ($gamification_message)
                <div class="mt-3 text-sm {{ $gamification_message['type'] === 'success' ? 'text-emerald-700' : 'text-red-600' }}">
                    {{ $gamification_message['text'] }}
                </div>
            @endif
        </div>

    </div>
</div>
