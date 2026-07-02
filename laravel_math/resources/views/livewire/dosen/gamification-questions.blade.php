<div>
    <div class="mb-6">
        <h1 class="text-2xl font-semibold text-slate-900">Soal Latihan (Gamifikasi)</h1>
        <p class="text-slate-500 text-sm mt-1">Kelola soal latihan/level yang sudah diimport.</p>
    </div>

    @if (session('success'))
        <div class="mb-4 bg-emerald-50 text-emerald-700 text-sm px-4 py-2.5 rounded-lg border border-emerald-200">
            {{ session('success') }}
        </div>
    @endif

    <div class="bg-white rounded-xl border border-slate-200 p-4 mb-4 grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">Cari Pertanyaan</label>
            <input type="text" wire:model.live.debounce.400ms="search" placeholder="Cari teks soal..."
                class="w-full rounded-lg border-slate-300 text-sm">
        </div>
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">Topik</label>
            <select wire:model.live="topic_filter" class="w-full rounded-lg border-slate-300 text-sm">
                <option value="">Semua Topik</option>
                @foreach ($topics as $topic)
                    <option value="{{ $topic->id }}">{{ $topic->title }}</option>
                @endforeach
            </select>
        </div>
        <div>
            <label class="block text-xs font-medium text-slate-600 mb-1">Tingkat Kesulitan</label>
            <select wire:model.live="difficulty_filter" class="w-full rounded-lg border-slate-300 text-sm">
                <option value="">Semua</option>
                <option value="easy">Easy</option>
                <option value="medium">Medium</option>
                <option value="hard">Hard</option>
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
                    <th class="text-left px-5 py-3">Pertanyaan</th>
                    <th class="text-left px-5 py-3">Topik</th>
                    <th class="text-left px-5 py-3">Kunci</th>
                    <th class="text-left px-5 py-3">Kesulitan</th>
                    <th class="text-right px-5 py-3">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($questions as $q)
                    <tr>
                        <td class="px-5 py-3 text-slate-900">{{ \Illuminate\Support\Str::limit($q->question_text, 80) }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $q->topic->title ?? '-' }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $q->correct_answer }}</td>
                        <td class="px-5 py-3">
                            <span class="text-xs px-2 py-1 rounded-full bg-slate-100 text-slate-600">{{ ucfirst($q->difficulty) }}</span>
                        </td>
                        <td class="px-5 py-3 text-right space-x-3">
                            <a href="{{ route('dosen.questions.edit', $q->id) }}" class="text-indigo-600 hover:underline text-xs font-medium">Edit</a>
                            <button type="button" wire:click="deleteQuestion({{ $q->id }})"
                                wire:confirm="Yakin ingin menghapus soal ini?"
                                class="text-red-600 hover:underline text-xs font-medium">Hapus</button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="px-5 py-8 text-center text-slate-400 text-sm">Belum ada soal latihan.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $questions->links() }}
    </div>
</div>
