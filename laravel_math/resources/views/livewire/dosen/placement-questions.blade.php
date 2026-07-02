<div>
    {{-- Header --}}
    <div class="mb-6">
        <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Soal Placement Test</h1>
        <p class="text-sm mt-1" style="color:#7C8DB5;">Kelola soal placement test yang sudah diimport.</p>
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

    {{-- Filter --}}
    <div class="bg-white rounded-2xl p-4 mb-4 grid grid-cols-1 md:grid-cols-3 gap-3 items-end"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Cari Pertanyaan</label>
            <input type="text" wire:model.live.debounce.400ms="search" placeholder="Cari teks soal..."
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
        </div>
        <div>
            <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Tingkat Kesulitan</label>
            <select wire:model.live="difficulty_filter"
                class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                <option value="">Semua</option>
                <option value="easy">Easy</option>
                <option value="medium">Medium</option>
                <option value="hard">Hard</option>
            </select>
        </div>
        <div>
            <button type="button" wire:click="resetFilters"
                class="w-full text-sm font-semibold rounded-xl px-3 py-2.5 transition-colors"
                style="color:#435273; border:1px solid #D0E2FF; background:#F5F8FC;"
                onmouseover="this.style.background='#F0F6FF'" onmouseout="this.style.background='#F5F8FC'">
                Reset Filter
            </button>
        </div>
    </div>

    {{-- Table --}}
    <div class="bg-white rounded-2xl overflow-hidden"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <table class="w-full text-sm">
            <thead style="background:#F5F8FC;">
                <tr>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Pertanyaan</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Kunci</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Kesulitan</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($questions as $q)
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-medium" style="color:#0F2D6B;">{{ \Illuminate\Support\Str::limit($q->question_text, 80) }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $q->correct_answer }}</td>
                        <td class="px-5 py-3.5">
                            <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F5F8FC; color:#435273;">{{ ucfirst($q->difficulty) }}</span>
                        </td>
                        <td class="px-5 py-3.5 text-right space-x-3">
                            <a href="{{ route('dosen.questions.edit', $q->id) }}"
                                class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Edit
                            </a>
                            <button type="button" wire:click="deleteQuestion({{ $q->id }})"
                                wire:confirm="Yakin ingin menghapus soal ini?"
                                class="text-xs font-semibold transition-colors" style="color:#E53935;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Hapus
                            </button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada soal placement.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $questions->links() }}
    </div>
</div>