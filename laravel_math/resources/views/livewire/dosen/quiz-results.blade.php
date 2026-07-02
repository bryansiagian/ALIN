<div>
    <div class="mb-6">
        <a href="{{ route('dosen.quizzes') }}" class="text-sm text-slate-500 hover:text-slate-700">← Kembali ke daftar kuis</a>
        <h1 class="text-2xl font-semibold text-slate-900 mt-2">Hasil: {{ $assignment->title }}</h1>
        <p class="text-slate-500 text-sm mt-1">{{ $sessions->count() }} mahasiswa mengerjakan kuis ini.</p>
    </div>

    {{-- Hasil per mahasiswa --}}
    <div class="bg-white rounded-xl border border-slate-200 overflow-hidden mb-8">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                <tr>
                    <th class="text-left px-5 py-3">Mahasiswa</th>
                    <th class="text-left px-5 py-3">NIM</th>
                    <th class="text-left px-5 py-3">Skor</th>
                    <th class="text-left px-5 py-3">Status</th>
                    <th class="text-left px-5 py-3">Pelanggaran</th>
                    <th class="text-left px-5 py-3">Waktu Submit</th>
                    <th class="text-right px-5 py-3">Detail</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($sessions as $session)
                    <tr>
                        <td class="px-5 py-3 font-medium text-slate-900">{{ $session->student_name }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $session->nim ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $session->total_score ?? '-' }}</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full
                                {{ $session->status === 'submitted' ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700' }}">
                                {{ ucfirst($session->status) }}
                            </span>
                        </td>
                        <td class="px-5 py-3 text-slate-600">{{ $session->violation_count }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $session->submitted_at ? \Carbon\Carbon::parse($session->submitted_at)->timezone('Asia/Jakarta')->format('d M Y, H:i') : '-' }}</td>
                        <td class="px-5 py-3 text-right">
                            <button type="button" wire:click="toggleExpand({{ $session->id }})" class="text-indigo-600 hover:underline text-xs font-medium">
                                {{ $expandedSession === $session->id ? 'Tutup' : 'Lihat Jawaban' }}
                            </button>
                        </td>
                    </tr>
                    @if ($expandedSession === $session->id)
                        <tr>
                            <td colspan="7" class="px-5 py-4 bg-slate-50">
                                <table class="w-full text-xs">
                                    <thead class="text-slate-500 uppercase">
                                        <tr>
                                            <th class="text-left py-2">Pertanyaan</th>
                                            <th class="text-left py-2">Jawaban Mahasiswa</th>
                                            <th class="text-left py-2">Kunci</th>
                                            <th class="text-left py-2">Benar?</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-slate-200">
                                        @foreach ($answers as $ans)
                                            <tr>
                                                <td class="py-2 pr-4">{{ $ans->question_text }}</td>
                                                <td class="py-2 pr-4">{{ $ans->user_answer }}</td>
                                                <td class="py-2 pr-4">{{ $ans->correct_answer }}</td>
                                                <td class="py-2">
                                                    <span class="{{ $ans->is_correct ? 'text-emerald-600' : 'text-red-600' }} font-medium">
                                                        {{ $ans->is_correct ? 'Benar' : 'Salah' }}
                                                    </span>
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
                        <td colspan="7" class="px-5 py-8 text-center text-slate-400 text-sm">Belum ada mahasiswa yang mengerjakan kuis ini.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Daftar soal --}}
    <div>
        <h2 class="font-semibold text-slate-900 mb-3">Soal dalam Kuis Ini</h2>
        <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                    <tr>
                        <th class="text-left px-5 py-3">#</th>
                        <th class="text-left px-5 py-3">Pertanyaan</th>
                        <th class="text-left px-5 py-3">Kunci</th>
                        <th class="text-right px-5 py-3">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    @foreach ($questions as $i => $q)
                        <tr>
                            <td class="px-5 py-3 text-slate-500">{{ $i + 1 }}</td>
                            <td class="px-5 py-3 text-slate-900">{{ \Illuminate\Support\Str::limit($q->question_text, 80) }}</td>
                            <td class="px-5 py-3 text-slate-600">{{ $q->correct_answer }}</td>
                            <td class="px-5 py-3 text-right">
                                <a href="{{ route('dosen.questions.edit', $q->id) }}" class="text-indigo-600 hover:underline text-xs font-medium">Edit Soal</a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
