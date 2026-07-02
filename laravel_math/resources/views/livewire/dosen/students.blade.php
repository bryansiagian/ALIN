<div>
    {{-- Header --}}
    <div class="mb-6">
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Daftar Mahasiswa</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">Lihat mahasiswa terdaftar dan riwayat pengerjaan soal mereka.</p>
    </div>

    {{-- Filter --}}
    <div class="bg-white rounded-2xl p-4 mb-4 grid grid-cols-1 md:grid-cols-6 gap-3 items-end"
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
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Min. Kuis Selesai</label>
            <input type="number" min="0" wire:model.live="min_completed" placeholder="cth: 2"
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
        </div>
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Grade Placement</label>
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
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Urutkan</label>
            <select wire:model.live="sort_by"
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                <option value="nim">NIM</option>
                <option value="name">Abjad (Nama)</option>
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
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Prodi</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Kuis Selesai</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Placement</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($students as $student)
                    @php $placement = $latestPlacements->get($student->id); @endphp
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $student->name }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $student->nim ?? '-' }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $student->prodi ?? '-' }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $student->completed_exams_count }}</td>
                        <td class="px-5 py-3.5">
                            @if ($placement)
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F0F6FF; color:#2F6FED;">
                                    {{ $placement->grade }} ({{ number_format($placement->score, 1) }})
                                </span>
                            @else
                                <span class="text-xs" style="color:#A9B6D6;">Belum tes</span>
                            @endif
                        </td>
                        <td class="px-5 py-3.5 text-right">
                            <a href="{{ route('dosen.students.detail', $student->id) }}"
                                class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Lihat Riwayat
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Tidak ada mahasiswa ditemukan.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $students->links() }}
    </div>
</div>