<div>
    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-slate-900">Rekap Placement Test</h1>
        <p class="text-slate-500 text-sm mt-1">Hasil placement test terbaru seluruh mahasiswa.</p>
    </div>

    <div class="bg-white rounded-xl border border-slate-200 p-4 mb-4 grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">Nama</label>
            <input type="text" wire:model.live.debounce.400ms="name" placeholder="Cari nama..."
                class="w-full rounded-lg border-slate-300 text-sm">
        </div>
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">NIM</label>
            <input type="text" wire:model.live.debounce.400ms="nim" placeholder="Cari NIM..."
                class="w-full rounded-lg border-slate-300 text-sm">
        </div>
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">Grade</label>
            <select wire:model.live="grade_filter" class="w-full rounded-lg border-slate-300 text-sm">
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
                class="w-full text-sm text-slate-600 hover:bg-slate-100 border border-slate-300 rounded-lg px-3 py-2">
                Reset Filter
            </button>
        </div>
    </div>

    <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                <tr>
                    <th class="text-left px-5 py-3">Nama</th>
                    <th class="text-left px-5 py-3">NIM</th>
                    <th class="text-left px-5 py-3">Skor</th>
                    <th class="text-left px-5 py-3">Grade</th>
                    <th class="text-left px-5 py-3">Level Terbuka</th>
                    <th class="text-left px-5 py-3">Tanggal</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($results as $r)
                    <tr>
                        <td class="px-5 py-3 font-medium text-slate-900">{{ $r->name }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $r->nim ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ number_format($r->score, 1) }}</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full bg-indigo-100 text-indigo-700">{{ $r->grade }}</span>
                        </td>
                        <td class="px-5 py-3 text-slate-600">{{ $r->unlocked_level }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ \Carbon\Carbon::parse($r->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-5 py-8 text-center text-slate-400 text-sm">Belum ada mahasiswa yang mengerjakan placement test.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $results->links() }}
    </div>
</div>
