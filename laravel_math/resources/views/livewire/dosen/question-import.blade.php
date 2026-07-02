<div>
    {{-- Header --}}
    <div class="mb-6">
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Upload Soal Massal</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">Import banyak soal sekaligus untuk Placement Test dan soal Latihan (Gamifikasi). Mendukung format CSV dan Excel (.xlsx).</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

        {{-- Placement Test --}}
        <div class="bg-white rounded-2xl p-6 space-y-4"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <div>
                <h2 class="font-['Space_Grotesk'] font-bold" style="color:#0F2D6B;">Soal Placement Test</h2>
                <p class="text-xs mt-1.5" style="color:#7C8DB5;">
                    Format kolom (baris pertama = header):<br>
                    <code class="px-1.5 py-0.5 rounded text-[11px]" style="background:#F0F6FF; color:#2F6FED;">question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs mt-1" style="color:#A9B6D6;">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard</p>
            </div>

            <form wire:submit="importPlacement" class="space-y-3">
                <div class="rounded-xl border border-dashed px-3.5 py-3" style="background:#F0F6FF; border-color:#D0E2FF;">
                    <input type="file" wire:model="placement_file" accept=".csv,.txt,.xlsx,.xls" class="w-full text-xs" style="color:#435273;">
                </div>
                @error('placement_file') <p class="text-xs" style="color:#E53935;">{{ $message }}</p> @enderror

                <button type="submit"
                    class="text-sm font-semibold text-white px-4 py-2.5 rounded-xl"
                    style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);"
                    wire:loading.attr="disabled" wire:target="importPlacement">
                    <span wire:loading.remove wire:target="importPlacement">Upload & Import</span>
                    <span wire:loading wire:target="importPlacement">Memproses...</span>
                </button>
            </form>

            @if ($placement_message)
                <div class="mt-3 text-sm font-medium" style="color:{{ $placement_message['type'] === 'success' ? '#047857' : '#E53935' }};">
                    {{ $placement_message['text'] }}
                </div>
            @endif
        </div>

        {{-- Gamifikasi --}}
        <div class="bg-white rounded-2xl p-6 space-y-4"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <div>
                <h2 class="font-['Space_Grotesk'] font-bold" style="color:#0F2D6B;">Soal Latihan (Gamifikasi / Level)</h2>
                <p class="text-xs mt-1.5" style="color:#7C8DB5;">
                    Format kolom (baris pertama = header):<br>
                    <code class="px-1.5 py-0.5 rounded text-[11px]" style="background:#F0F6FF; color:#2F6FED;">topic_id,question_text,option_a,option_b,option_c,option_d,correct_answer,difficulty</code>
                </p>
                <p class="text-xs mt-1" style="color:#A9B6D6;">correct_answer: A/B/C/D &middot; difficulty: easy/medium/hard &middot; topic_id boleh berbeda-beda tiap baris</p>
            </div>

            <form wire:submit="importGamification" class="space-y-3">
                <div class="rounded-xl border border-dashed px-3.5 py-3" style="background:#F0F6FF; border-color:#D0E2FF;">
                    <input type="file" wire:model="gamification_file" accept=".csv,.txt,.xlsx,.xls" class="w-full text-xs" style="color:#435273;">
                </div>
                @error('gamification_file') <p class="text-xs" style="color:#E53935;">{{ $message }}</p> @enderror

                <button type="submit"
                    class="text-sm font-semibold text-white px-4 py-2.5 rounded-xl"
                    style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);"
                    wire:loading.attr="disabled" wire:target="importGamification">
                    <span wire:loading.remove wire:target="importGamification">Upload & Import</span>
                    <span wire:loading wire:target="importGamification">Memproses...</span>
                </button>
            </form>

            @if ($gamification_message)
                <div class="mt-3 text-sm font-medium" style="color:{{ $gamification_message['type'] === 'success' ? '#047857' : '#E53935' }};">
                    {{ $gamification_message['text'] }}
                </div>
            @endif
        </div>

    </div>
</div>