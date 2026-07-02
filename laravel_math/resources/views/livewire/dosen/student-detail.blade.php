<div>
    {{-- Header --}}
    <div class="mb-6">
        <a href="{{ route('dosen.students') }}"
            class="inline-flex items-center gap-1 text-sm font-medium transition-colors" style="color:#7C8DB5;"
            onmouseover="this.style.color='#2F6FED'" onmouseout="this.style.color='#7C8DB5'">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Kembali ke daftar mahasiswa
        </a>
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold mt-2" style="color:#0F2D6B;">{{ $student->name }}</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">
            NIM: {{ $student->nim ?? '-' }} &middot; Prodi: {{ $student->prodi ?? '-' }} &middot; {{ $student->email }}
        </p>
    </div>

    {{-- Riwayat Kuis --}}
    <div class="mb-8">
        <h2 class="font-['Space_Grotesk'] font-bold mb-3" style="color:#0F2D6B;">Riwayat Kuis</h2>
        <div class="bg-white rounded-2xl overflow-hidden"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <table class="w-full text-sm">
                <thead style="background:#F5F8FC;">
                    <tr>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Kuis</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Skor</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Status</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Pelanggaran</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Mulai</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Selesai</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($examSessions as $session)
                        <tr style="border-top:1px solid #F0F4FC;">
                            <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $session->quiz_title }}</td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ $session->total_score ?? '-' }}</td>
                            <td class="px-5 py-3.5">
                                @if ($session->status === 'submitted')
                                    <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#ECFDF5; color:#047857;">Submitted</span>
                                @else
                                    <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#FFFBEB; color:#B45309;">{{ ucfirst($session->status) }}</span>
                                @endif
                            </td>
                            <td class="px-5 py-3.5" style="color:{{ $session->violation_count > 0 ? '#E53935' : '#435273' }}; {{ $session->violation_count > 0 ? 'font-weight:600;' : '' }}">
                                {{ $session->violation_count }}
                            </td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ $session->started_at ? \Carbon\Carbon::parse($session->started_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ $session->submitted_at ? \Carbon\Carbon::parse($session->submitted_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                                Mahasiswa ini belum mengerjakan kuis.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- Riwayat Placement Test --}}
    <div>
        <h2 class="font-['Space_Grotesk'] font-bold mb-3" style="color:#0F2D6B;">Riwayat Placement Test</h2>
        <div class="bg-white rounded-2xl overflow-hidden"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <table class="w-full text-sm">
                <thead style="background:#F5F8FC;">
                    <tr>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Skor</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Grade</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Level Terbuka</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Tanggal</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($placementHistory as $result)
                        <tr style="border-top:1px solid #F0F4FC;">
                            <td class="px-5 py-3.5" style="color:#435273;">{{ number_format($result->score, 1) }}</td>
                            <td class="px-5 py-3.5">
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F0F6FF; color:#2F6FED;">{{ $result->grade }}</span>
                            </td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ $result->unlocked_level }}</td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ \Carbon\Carbon::parse($result->created_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') }}</td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                                Belum pernah mengerjakan placement test.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
