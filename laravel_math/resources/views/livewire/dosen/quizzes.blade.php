<div>
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="text-2xl font-semibold text-slate-900">Kelola Kuis</h1>
            <p class="text-slate-500 text-sm mt-1">Buat dan kelola kuis pilihan ganda untuk mahasiswa.</p>
        </div>
        <a href="{{ route('dosen.quizzes.create') }}" class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg">
            + Buat Kuis Baru
        </a>
    </div>

    @if (session('success'))
        <div class="mb-4 bg-emerald-50 text-emerald-700 text-sm px-4 py-2.5 rounded-lg border border-emerald-200">
            {{ session('success') }}
        </div>
    @endif

    <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                <tr>
                    <th class="text-left px-5 py-3">Judul Kuis</th>
                    <th class="text-left px-5 py-3">Topik</th>
                    <th class="text-left px-5 py-3">Soal</th>
                    <th class="text-left px-5 py-3">Deadline</th>
                    <th class="text-left px-5 py-3">Peserta</th>
                    <th class="text-left px-5 py-3">Status</th>
                    <th class="text-right px-5 py-3">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($quizzes as $quiz)
                    <tr>
                        <td class="px-5 py-3 font-medium text-slate-900">{{ $quiz->title }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $quiz->topic->title ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $quiz->question_count }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $quiz->deadline->format('d M Y, H:i') }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $quiz->exam_sessions_count }}</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full
                                {{ $quiz->status === 'published' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-500' }}">
                                {{ ucfirst($quiz->status) }}
                            </span>
                        </td>
                        <td class="px-5 py-3 text-right">
                            @if (\Illuminate\Support\Facades\Route::has('dosen.quizzes.detail'))
                                <a href="{{ route('dosen.quizzes.detail', $quiz->id) }}" class="text-indigo-600 hover:underline text-xs font-medium">Detail</a>
                            @else
                                <span class="text-slate-300 text-xs">Detail (segera hadir)</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-5 py-8 text-center text-slate-400 text-sm">Belum ada kuis.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
