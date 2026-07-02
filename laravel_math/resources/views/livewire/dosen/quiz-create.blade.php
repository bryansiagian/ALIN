<div>
    <div class="mb-6">
        <a href="{{ route('dosen.quizzes') }}" class="text-sm text-slate-500 hover:text-slate-700">← Kembali ke daftar kuis</a>
        <h1 class="text-2xl font-semibold text-slate-900 mt-2">Buat Kuis Baru</h1>
    </div>

    <form wire:submit="save" class="space-y-8">
        {{-- Metadata Kuis --}}
        <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
            <h2 class="font-semibold text-slate-900">Informasi Kuis</h2>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Topik</label>
                    <select wire:model="topic_id" class="w-full rounded-lg border-slate-300 text-sm">
                        <option value="">-- Pilih Topik --</option>
                        @foreach ($topics as $topic)
                            <option value="{{ $topic->id }}">{{ $topic->title }}</option>
                        @endforeach
                    </select>
                    @error('topic_id') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Judul Kuis</label>
                    <input type="text" wire:model="title" class="w-full rounded-lg border-slate-300 text-sm">
                    @error('title') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Deskripsi</label>
                <textarea wire:model="description" rows="2" class="w-full rounded-lg border-slate-300 text-sm"></textarea>
            </div>

            <div class="grid grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Waktu Mulai</label>
                    <input type="datetime-local" wire:model="start_time" class="w-full rounded-lg border-slate-300 text-sm">
                    @error('start_time') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Deadline</label>
                    <input type="datetime-local" wire:model="deadline" class="w-full rounded-lg border-slate-300 text-sm">
                    @error('deadline') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Durasi (menit)</label>
                    <input type="number" wire:model="duration_minutes" class="w-full rounded-lg border-slate-300 text-sm">
                    @error('duration_minutes') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input type="checkbox" wire:model="is_safe_exam" class="rounded border-slate-300 text-indigo-600">
                    Mode Ujian Aman (Safe Exam Browser)
                </label>
                <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input type="checkbox" wire:model="show_results" class="rounded border-slate-300 text-indigo-600">
                    Tampilkan hasil ke mahasiswa
                </label>
                <label class="flex items-center gap-2 text-sm text-slate-700">
                    <input type="checkbox" wire:model="allow_reattempt" class="rounded border-slate-300 text-indigo-600">
                    Izinkan mengulang
                </label>
                <div>
                    <label class="block text-sm font-medium text-slate-700 mb-1">Batas Percobaan</label>
                    <input type="number" wire:model="attempt_limit" min="1" class="w-full rounded-lg border-slate-300 text-sm">
                </div>
            </div>

            <div>
                <label class="block text-sm font-medium text-slate-700 mb-1">Password Kuis (opsional)</label>
                <input type="text" wire:model="password" class="w-full rounded-lg border-slate-300 text-sm" placeholder="Kosongkan jika tidak perlu password">
            </div>
        </div>

        {{-- Daftar Soal --}}
        <div class="space-y-4">
            <div class="flex items-center justify-between">
                <h2 class="font-semibold text-slate-900">Soal ({{ count($questions) }})</h2>
                <button type="button" wire:click="addQuestion" class="text-sm text-indigo-600 hover:underline font-medium">+ Tambah Soal</button>
            </div>

            @foreach ($questions as $qIndex => $question)
                <div class="bg-white rounded-xl border border-slate-200 p-6 space-y-4" wire:key="question-{{ $qIndex }}">
                    <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-slate-500">Soal #{{ $qIndex + 1 }}</span>
                        @if (count($questions) > 1)
                            <button type="button" wire:click="removeQuestion({{ $qIndex }})" class="text-xs text-red-600 hover:underline">Hapus Soal</button>
                        @endif
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Pertanyaan</label>
                        <textarea wire:model="questions.{{ $qIndex }}.text" rows="2" class="w-full rounded-lg border-slate-300 text-sm"></textarea>
                        @error("questions.{$qIndex}.text") <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Gambar Soal (opsional)</label>
                        <input type="file" wire:model="questions.{{ $qIndex }}.image" accept="image/*" class="text-sm">
                        @if ($question['image'])
                            <img src="{{ $question['image']->temporaryUrl() }}" class="mt-2 h-24 rounded-lg border border-slate-200">
                        @endif
                        @error("questions.{$qIndex}.image") <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div class="space-y-3">
                        <label class="block text-sm font-medium text-slate-700">Opsi Jawaban</label>
                        @foreach ($question['options'] as $oIndex => $option)
                            <div class="flex gap-3 items-start bg-slate-50 rounded-lg p-3" wire:key="q{{ $qIndex }}-opt{{ $oIndex }}">
                                <label class="flex items-center gap-2 pt-2">
                                    <input type="radio"
                                        wire:model="questions.{{ $qIndex }}.correct_answer"
                                        value="{{ $option['key'] }}"
                                        class="text-indigo-600">
                                    <span class="text-sm font-semibold text-slate-700 w-5">{{ $option['key'] }}</span>
                                </label>
                                <div class="flex-1 space-y-2">
                                    <input type="text"
                                        wire:model="questions.{{ $qIndex }}.options.{{ $oIndex }}.text"
                                        placeholder="Teks opsi {{ $option['key'] }}"
                                        class="w-full rounded-lg border-slate-300 text-sm">
                                    <input type="file"
                                        wire:model="questions.{{ $qIndex }}.options.{{ $oIndex }}.image"
                                        accept="image/*" class="text-xs">
                                    @if ($option['image'])
                                        <img src="{{ $option['image']->temporaryUrl() }}" class="h-16 rounded-lg border border-slate-200">
                                    @endif
                                </div>
                            </div>
                        @endforeach
                        <p class="text-xs text-slate-400">Pilih radio button di samping huruf untuk menandai jawaban benar.</p>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="flex justify-end gap-3 pb-8">
            <a href="{{ route('dosen.quizzes') }}" class="px-5 py-2.5 text-sm text-slate-600 hover:bg-slate-100 rounded-lg">Batal</a>
            <button type="submit"
                class="px-5 py-2.5 text-sm bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-medium">
                <span wire:loading.remove wire:target="save">Terbitkan Kuis</span>
                <span wire:loading wire:target="save">Menyimpan...</span>
            </button>
        </div>
    </form>
</div>
