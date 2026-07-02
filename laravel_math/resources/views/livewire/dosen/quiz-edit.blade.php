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
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold mt-2" style="color:#0F2D6B;">Edit Kuis</h1>
    </div>

    <form wire:submit="update" class="space-y-8">
        {{-- Metadata Kuis --}}
        <div class="bg-white rounded-2xl p-6 space-y-4"
            style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
            <h2 class="font-['Space_Grotesk'] font-bold" style="color:#0F2D6B;">Informasi Kuis</h2>

            <div>
                <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Judul Kuis</label>
                <input type="text" wire:model="title"
                    class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                    style="background:#F0F6FF; border-color:{{ $errors->has('title') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                @error('title') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
            </div>

            <div>
                <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Deskripsi</label>
                <textarea wire:model="description" rows="2"
                    class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                    style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;"></textarea>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Waktu Mulai</label>
                    <input type="datetime-local" wire:model="start_time"
                        class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                        style="background:#F0F6FF; border-color:{{ $errors->has('start_time') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                    @error('start_time') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                </div>
                <div>
                    <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Deadline</label>
                    <input type="datetime-local" wire:model="deadline"
                        class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                        style="background:#F0F6FF; border-color:{{ $errors->has('deadline') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                    @error('deadline') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
                <label class="flex items-center gap-2.5 text-sm font-medium cursor-pointer" style="color:#435273;">
                    <input type="checkbox" wire:model.live="is_safe_exam" class="w-4 h-4 rounded" style="border-color:#D0E2FF; accent-color:#2F6FED;">
                    Mode Ujian Aman (Safe Exam Browser)
                </label>
                <label class="flex items-center gap-2.5 text-sm font-medium cursor-pointer" style="color:#435273;">
                    <input type="checkbox" wire:model.live="show_results" class="w-4 h-4 rounded" style="border-color:#D0E2FF; accent-color:#2F6FED;">
                    Tampilkan hasil ke mahasiswa
                </label>
                <label class="flex items-center gap-2.5 text-sm font-medium cursor-pointer" style="color:#435273;">
                    <input type="checkbox" wire:model.live="allow_reattempt" class="w-4 h-4 rounded" style="border-color:#D0E2FF; accent-color:#2F6FED;">
                    Izinkan mengulang
                </label>
            </div>

            @if ($allow_reattempt)
                <div>
                    <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Batas Percobaan</label>
                    <input type="number" wire:model="attempt_limit" min="1"
                        class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                        style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                </div>
            @endif

            <div>
                <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Password Kuis (opsional)</label>
                <input type="text" wire:model="password" placeholder="Kosongkan jika tidak perlu password"
                    class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                    style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
            </div>
        </div>

        {{-- Daftar Soal --}}
        <div class="space-y-4">
            <div class="flex items-center justify-between">
                <h2 class="font-['Space_Grotesk'] font-bold" style="color:#0F2D6B;">Soal ({{ count($questions) }})</h2>
                <button type="button" wire:click="addQuestion"
                    class="flex items-center gap-1.5 text-sm font-semibold transition-colors" style="color:#2F6FED;"
                    onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                    </svg>
                    Tambah Soal
                </button>
            </div>

            @foreach ($questions as $qIndex => $question)
                <div class="bg-white rounded-2xl p-6 space-y-4" wire:key="question-{{ $qIndex }}"
                    style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold uppercase tracking-wider" style="color:#7C8DB5;">Soal #{{ $qIndex + 1 }}</span>
                        @if (count($questions) > 1)
                            <button type="button" wire:click="removeQuestion({{ $qIndex }})"
                                class="text-xs font-semibold transition-colors" style="color:#E53935;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Hapus Soal
                            </button>
                        @endif
                    </div>

                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Pertanyaan</label>
                        <textarea wire:model="questions.{{ $qIndex }}.text" rows="2"
                            class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#F0F6FF; border-color:{{ $errors->has("questions.$qIndex.text") ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;"></textarea>
                        @error("questions.{$qIndex}.text") <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Gambar Soal (opsional)</label>
                        <div class="rounded-xl border border-dashed px-3.5 py-3" style="background:#F0F6FF; border-color:#D0E2FF;">
                            <input type="file" wire:model="questions.{{ $qIndex }}.image" accept="image/*" class="w-full text-xs" style="color:#435273;">
                        </div>
                        @if ($question['image'])
                            <img src="{{ $question['image']->temporaryUrl() }}" class="mt-2 h-24 rounded-xl" style="border:1px solid #E3EBFA;">
                        @elseif ($question['existing_image'])
                            <div class="relative inline-block mt-2">
                                <img src="{{ $question['existing_image'] }}" class="h-24 rounded-xl" style="border:1px solid #E3EBFA;">
                                <button type="button" wire:click="removeQuestionImage({{ $qIndex }})"
                                    class="absolute -top-2 -right-2 text-white rounded-full w-5 h-5 text-xs leading-none flex items-center justify-center"
                                    style="background:#E53935;">×</button>
                            </div>
                        @endif
                        @error("questions.{$qIndex}.image") <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                    </div>

                    <div class="space-y-3">
                        <label class="block text-xs font-semibold" style="color:#0F2D6B;">Opsi Jawaban</label>
                        @foreach ($question['options'] as $oIndex => $option)
                            <div class="flex gap-3 items-start rounded-xl p-3" wire:key="q{{ $qIndex }}-opt{{ $oIndex }}"
                                style="background:{{ $question['correct_answer'] === $option['key'] ? '#F0F6FF' : '#F5F8FC' }}; border:1px solid {{ $question['correct_answer'] === $option['key'] ? '#D0E2FF' : '#F0F4FC' }};">
                                <label class="flex items-center gap-2 pt-2">
                                    <input type="radio"
                                        wire:model="questions.{{ $qIndex }}.correct_answer"
                                        value="{{ $option['key'] }}"
                                        class="w-4 h-4" style="accent-color:#2F6FED;">
                                    <span class="text-sm font-bold w-5" style="color:#0F2D6B;">{{ $option['key'] }}</span>
                                </label>
                                <div class="flex-1 space-y-2">
                                    <input type="text"
                                        wire:model="questions.{{ $qIndex }}.options.{{ $oIndex }}.text"
                                        placeholder="Teks opsi {{ $option['key'] }}"
                                        class="w-full rounded-lg border pl-3 pr-3 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                                        style="background:#FFFFFF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                                    <input type="file"
                                        wire:model="questions.{{ $qIndex }}.options.{{ $oIndex }}.image"
                                        accept="image/*" class="text-xs" style="color:#7C8DB5;">
                                    @if ($option['image'])
                                        <img src="{{ $option['image']->temporaryUrl() }}" class="h-16 rounded-lg" style="border:1px solid #E3EBFA;">
                                    @elseif ($option['existing_image'])
                                        <div class="relative inline-block">
                                            <img src="{{ $option['existing_image'] }}" class="h-16 rounded-lg" style="border:1px solid #E3EBFA;">
                                            <button type="button" wire:click="removeOptionImage({{ $qIndex }}, {{ $oIndex }})"
                                                class="absolute -top-2 -right-2 text-white rounded-full w-5 h-5 text-xs leading-none flex items-center justify-center"
                                                style="background:#E53935;">×</button>
                                        </div>
                                    @endif
                                </div>
                            </div>
                        @endforeach
                        <p class="text-xs" style="color:#A9B6D6;">Pilih radio button di samping huruf untuk menandai jawaban benar.</p>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="flex justify-end gap-2 pb-8">
            <a href="{{ route('dosen.quizzes') }}"
                class="px-4 py-2.5 text-sm font-semibold rounded-xl transition-colors" style="color:#435273;"
                onmouseover="this.style.background='#F0F6FF'" onmouseout="this.style.background=''">
                Batal
            </a>
            <button type="submit"
                class="px-5 py-2.5 text-sm font-semibold text-white rounded-xl"
                style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
                <span wire:loading.remove wire:target="update">Simpan Perubahan</span>
                <span wire:loading wire:target="update">Menyimpan...</span>
            </button>
        </div>
    </form>
</div>
