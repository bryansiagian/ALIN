<div>
    {{-- Header --}}
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Kelola Kuis</h1>
            <p class="text-sm mt-1" style="color:#7C8DB5;">Buat dan kelola kuis pilihan ganda untuk mahasiswa.</p>
        </div>
        <a href="{{ route('dosen.quizzes.create') }}"
            class="flex items-center gap-1.5 text-white text-sm font-semibold px-4 py-2.5 rounded-xl transition-transform hover:-translate-y-0.5"
            style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Buat Kuis Baru
        </a>
    </div>

    {{-- Flash message --}}
    @if (session('success'))
        <div class="flex items-center gap-2 mb-4 text-sm px-4 py-2.5 rounded-xl"
            style="background:#ECFDF5; border:1px solid #A7F3D0; color:#047857;">
            <svg class="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            {{ session('success') }}
        </div>
    @endif

    {{-- Table card --}}
    <div class="bg-white rounded-2xl overflow-hidden"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <table class="w-full text-sm">
            <thead style="background:#F5F8FC;">
                <tr>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Judul Kuis</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Topik</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Soal</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Deadline</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Peserta</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Status</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($quizzes as $quiz)
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $quiz->title }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $quiz->topic->title ?? '-' }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $quiz->question_count }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $quiz->deadline->format('d M Y, H:i') }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $quiz->exam_sessions_count }}</td>
                        <td class="px-5 py-3.5">
                            @if ($quiz->status === 'published')
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#ECFDF5; color:#047857;">Published</span>
                            @else
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F1F5F9; color:#64748B;">{{ ucfirst($quiz->status) }}</span>
                            @endif
                        </td>
                        <td class="px-5 py-3.5 text-right space-x-3">
                            <a href="{{ route('dosen.quizzes.results', $quiz->id) }}"
                                class="text-xs font-semibold transition-colors" style="color:#047857;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Hasil
                            </a>
                            <a href="{{ route('dosen.quizzes.edit', $quiz->id) }}"
                                class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Edit
                            </a>
                            <button
                                type="button"
                                wire:click="deleteQuiz({{ $quiz->id }})"
                                wire:confirm="Yakin ingin menghapus kuis '{{ $quiz->title }}'? Semua soal dan hasil terkait akan ikut terhapus."
                                class="text-xs font-semibold transition-colors" style="color:#E53935;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Hapus
                            </button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada kuis. Klik "Buat Kuis Baru" untuk membuat yang pertama.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
