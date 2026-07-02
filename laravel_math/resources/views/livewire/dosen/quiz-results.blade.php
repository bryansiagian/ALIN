<div>
    {{-- Header --}}
    <div class="mb-6">
        <a href="{{ route('dosen.quizzes') }}"
            class="inline-flex items-center gap-1 text-sm font-medium transition-colors" style="color:#7C8DB5;"
            onmouseover="this.style.color='#2F6FED'" onmouseout="this.style.color='#7C8DB5'">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
            </svg>
            Kembali ke daftar kuis
        </a>
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold mt-2" style="color:#0F2D6B;">Hasil: {{ $assignment->title }}</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">{{ $sessions->count() }} mahasiswa mengerjakan kuis ini.</p>
    </div>

    {{-- Hasil per mahasiswa --}}
    <div class="bg-white rounded-2xl overflow-hidden mb-8"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <table class="w-full text-sm">
            <thead style="background:#F5F8FC;">
                <tr>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Mahasiswa</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">NIM</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Skor</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Status</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Pelanggaran</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Waktu Submit</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Detail</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($sessions as $session)
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $session->student_name }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $session->nim ?? '-' }}</td>
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
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $session->submitted_at ? \Carbon\Carbon::parse($session->submitted_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                        <td class="px-5 py-3.5 text-right">
                            <button type="button" wire:click="toggleExpand({{ $session->id }})"
                                class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                {{ $expandedSession === $session->id ? 'Tutup' : 'Lihat Jawaban' }}
                            </button>
                        </td>
                    </tr>
                    @if ($expandedSession === $session->id)
                        <tr>
                            <td colspan="7" class="px-5 py-4" style="background:#F5F8FC;">
                                <table class="w-full text-xs">
                                    <thead>
                                        <tr>
                                            <th class="text-left py-2 font-bold uppercase tracking-wider text-[10px]" style="color:#7C8DB5;">Pertanyaan</th>
                                            <th class="text-left py-2 font-bold uppercase tracking-wider text-[10px]" style="color:#7C8DB5;">Jawaban Mahasiswa</th>
                                            <th class="text-left py-2 font-bold uppercase tracking-wider text-[10px]" style="color:#7C8DB5;">Kunci</th>
                                            <th class="text-left py-2 font-bold uppercase tracking-wider text-[10px]" style="color:#7C8DB5;">Benar?</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        @foreach ($answers as $ans)
                                            <tr style="border-top:1px solid #E3EBFA;">
                                                <td class="py-2 pr-4" style="color:#0F2D6B;">{{ $ans->question_text }}</td>
                                                <td class="py-2 pr-4" style="color:#435273;">{{ $ans->user_answer }}</td>
                                                <td class="py-2 pr-4" style="color:#435273;">{{ $ans->correct_answer }}</td>
                                                <td class="py-2">
                                                    @if ($ans->is_correct)
                                                        <span class="font-semibold" style="color:#047857;">Benar</span>
                                                    @else
                                                        <span class="font-semibold" style="color:#E53935;">Salah</span>
                                                    @endif
                                                </td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    @endif
                @empty
                    <tr>
                        <td colspan="7" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada mahasiswa yang mengerjakan kuis ini.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Daftar soal --}}
    <div>
        <h2 class="font-['Space_Grotesk'] font-bold mb-3" style="color:#0F2D6B;">Soal dalam Kuis Ini</h2>
        <div class="bg-white rounded-2xl overflow-hidden"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <table class="w-full text-sm">
                <thead style="background:#F5F8FC;">
                    <tr>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">#</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Pertanyaan</th>
                        <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Kunci</th>
                        <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($questions as $i => $q)
                        <tr style="border-top:1px solid #F0F4FC;">
                            <td class="px-5 py-3.5" style="color:#A9B6D6;">{{ $i + 1 }}</td>
                            <td class="px-5 py-3.5 font-medium" style="color:#0F2D6B;">{{ \Illuminate\Support\Str::limit($q->question_text, 80) }}</td>
                            <td class="px-5 py-3.5" style="color:#435273;">{{ $q->correct_answer }}</td>
                            <td class="px-5 py-3.5 text-right">
                                <a href="{{ route('dosen.questions.edit', $q->id) }}"
                                    class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                    onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                    Edit Soal
                                </a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
