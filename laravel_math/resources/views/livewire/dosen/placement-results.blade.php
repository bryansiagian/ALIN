<div>
    {{-- Header --}}
    <div class="mb-6">
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Rekap Placement Test</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">Hasil placement test terbaru seluruh mahasiswa.</p>
    </div>

    {{-- Filter --}}
    <div class="bg-white rounded-2xl p-4 mb-4 grid grid-cols-1 md:grid-cols-4 gap-3 items-end"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Nama</label>
            <input type="text" wire:model.live.debounce.400ms="name" placeholder="Cari nama..."
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
        </div>
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">NIM</label>
            <input type="text" wire:model.live.debounce.400ms="nim" placeholder="Cari NIM..."
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
        </div>
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Grade</label>
            <select wire:model.live="grade_filter"
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                <option value="">Semua</option>
                <option value="A">A</option>
                <option value="AB">AB</option>
                <option value="B">B</option>
                <option value="BC">BC</option>
                <option value="C">C</option>
                <option value="D">D</option>
                <option value="E">E</option>
            </select>
        </div>
        <div>
            <button type="button" wire:click="resetFilters"
                class="w-full text-sm font-semibold rounded-xl px-3 py-2.5 transition-colors"
                style="color:#435273; border:1px solid #D0E2FF; background:#F5F8FC;"
                onmouseover="this.style.background='#F0F6FF'" onmouseout="this.style.background='#F5F8FC'">
                Reset Filter
            </button>
        </div>
    </div>

    {{-- Table --}}
    <div class="bg-white rounded-2xl overflow-hidden"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <table class="w-full text-sm">
            <thead style="background:#F5F8FC;">
                <tr>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Nama</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">NIM</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Skor</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Grade</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Level Terbuka</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Tanggal</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($results as $r)
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $r->name }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $r->nim ?? '-' }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ number_format($r->score, 1) }}</td>
                        <td class="px-5 py-3.5">
                            <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F0F6FF; color:#2F6FED;">{{ $r->grade }}</span>
                        </td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $r->unlocked_level }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ \Carbon\Carbon::parse($r->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada mahasiswa yang mengerjakan placement test.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $results->links() }}
    </div>
</div>
