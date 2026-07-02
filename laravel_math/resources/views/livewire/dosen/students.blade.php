<div>
    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-slate-900">Daftar Mahasiswa</h1>
        <p class="text-slate-500 text-sm mt-1">Lihat mahasiswa terdaftar dan riwayat pengerjaan soal mereka.</p>
    </div>

    <div class="mb-4">
        <input type="text" wire:model.live.debounce.400ms="search" placeholder="Cari nama atau NIM..."
            class="w-full max-w-sm rounded-lg border-slate-300 text-sm">
    </div>

    <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                <tr>
                    <th class="text-left px-5 py-3">Nama</th>
                    <th class="text-left px-5 py-3">NIM</th>
                    <th class="text-left px-5 py-3">Prodi</th>
                    <th class="text-left px-5 py-3">Kuis Selesai</th>
                    <th class="text-left px-5 py-3">Placement</th>
                    <th class="text-right px-5 py-3">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($students as $student)
                    @php $placement = $latestPlacements->get($student->id); @endphp
                    <tr>
                        <td class="px-5 py-3 font-medium text-slate-900">{{ $student->name }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $student->nim ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $student->prodi ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $student->completed_exams_count }}</td>
                        <td class="px-5 py-3">
                            @if ($placement)
                                <span class="text-xs px-2 py-1 rounded-full bg-indigo-100 text-indigo-700">
                                    {{ $placement->grade }} ({{ number_format($placement->score, 1) }})
                                </span>
                            @else
                                <span class="text-xs text-slate-400">Belum tes</span>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-right">
                            <a href="{{ route('dosen.students.detail', $student->id) }}" class="text-indigo-600 hover:underline text-xs font-medium">Lihat Riwayat</a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-5 py-8 text-center text-slate-400 text-sm">Tidak ada mahasiswa ditemukan.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $students->links() }}
    </div>
</div>
