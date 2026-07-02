<div>
    <div class="mb-6">
        <a href="{{ route('dosen.students') }}" class="text-sm text-slate-500 hover:text-slate-700">← Kembali ke daftar mahasiswa</a>
        <h1 class="text-2xl font-semibold text-slate-900 mt-2">{{ $student->name }}</h1>
        <p class="text-slate-500 text-sm mt-1">
            NIM: {{ $student->nim ?? '-' }} &middot; Prodi: {{ $student->prodi ?? '-' }} &middot; {{ $student->email }}
        </p>
    </div>

    {{-- Riwayat Kuis --}}
    <div class="mb-8">
        <h2 class="font-semibold text-slate-900 mb-3">Riwayat Kuis</h2>
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                    <tr>
                        <th class="text-left px-5 py-3">Kuis</th>
                        <th class="text-left px-5 py-3">Skor</th>
                        <th class="text-left px-5 py-3">Status</th>
                        <th class="text-left px-5 py-3">Pelanggaran</th>
                        <th class="text-left px-5 py-3">Mulai</th>
                        <th class="text-left px-5 py-3">Selesai</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    @forelse ($examSessions as $session)
                        <tr>
                            <td class="px-5 py-3 font-medium text-slate-900">{{ $session->quiz_title }}</td>
                            <td class="px-5 py-3 text-slate-600">{{ $session->total_score ?? '-' }}</td>
                            <td class="px-5 py-3">
                                <span class="text-xs px-2 py-1 rounded-full
                                    {{ $session->status === 'submitted' ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700' }}">
                                    {{ ucfirst($session->status) }}
                                </span>
                            </td>
                            <td class="px-5 py-3 text-slate-600">{{ $session->violation_count }}</td>
                            <td class="px-5 py-3 text-slate-600">{{ $session->started_at ? \Carbon\Carbon::parse($session->started_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                            <td class="px-5 py-3 text-slate-600">{{ $session->submitted_at ? \Carbon\Carbon::parse($session->submitted_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-5 py-8 text-center text-slate-400 text-sm">Mahasiswa ini belum mengerjakan kuis.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Riwayat Placement Test --}}
    <div>
        <h2 class="font-semibold text-slate-900 mb-3">Riwayat Placement Test</h2>
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                    <tr>
                        <th class="text-left px-5 py-3">Skor</th>
                        <th class="text-left px-5 py-3">Grade</th>
                        <th class="text-left px-5 py-3">Level Terbuka</th>
                        <th class="text-left px-5 py-3">Tanggal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    @forelse ($placementHistory as $result)
                        <tr>
                            <td class="px-5 py-3 text-slate-600">{{ number_format($result->score, 1) }}</td>
                            <td class="px-5 py-3">
                                <span class="text-xs px-2 py-1 rounded-full bg-indigo-100 text-indigo-700">{{ $result->grade }}</span>
                            </td>
                            <td class="px-5 py-3 text-slate-600">{{ $result->unlocked_level }}</td>
                            <td class="px-5 py-3 text-slate-600">{{ \Carbon\Carbon::parse($result->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-8 text-center text-slate-400 text-sm">Belum pernah mengerjakan placement test.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
