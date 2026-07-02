<div>
    {{-- Header --}}
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Kelola Materi</h1>
            <p class="text-sm mt-1" style="color:#7C8DB5;">Upload materi PDF per topik untuk mahasiswa.</p>
        </div>
        <button wire:click="openCreate"
            class="flex items-center gap-1.5 text-white text-sm font-semibold px-4 py-2.5 rounded-xl transition-transform hover:-translate-y-0.5"
            style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Upload Materi
        </button>
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
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Judul Materi</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Topik</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">File</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse ($materials as $material)
                    <tr style="border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5 font-semibold" style="color:#0F2D6B;">{{ $material->title }}</td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $material->topic->title ?? '-' }}</td>
                        <td class="px-5 py-3.5">
                            <a href="{{ $material->file_url }}" target="_blank"
                                class="inline-flex items-center gap-1 text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Lihat PDF
                                <svg class="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 19.5l15-15m0 0H8.25m11.25 0v11.25" />
                                </svg>
                            </a>
                        </td>
                        <td class="px-5 py-3.5 text-right space-x-3">
                            <button wire:click="openEdit({{ $material->id }})"
                                class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Edit
                            </button>
                            <button wire:click="delete({{ $material->id }})"
                                wire:confirm="Yakin mau hapus materi ini? File PDF juga akan terhapus."
                                class="text-xs font-semibold transition-colors" style="color:#E53935;"
                                onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                Hapus
                            </button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada materi. Klik "Upload Materi" untuk menambahkan yang pertama.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    {{-- Modal Create/Edit --}}
    @if ($showModal)
        <div class="fixed inset-0 flex items-center justify-center z-50 px-4" style="background:rgba(15,45,107,0.35);" wire:click.self="$set('showModal', false)">
            <div class="bg-white rounded-2xl w-full max-w-md p-6" style="box-shadow: 0 20px 48px -12px rgba(15,45,107,0.35);">
                <h2 class="font-['Space_Grotesk'] text-lg font-bold mb-5" style="color:#0F2D6B;">
                    {{ $editingId ? 'Edit Materi' : 'Upload Materi' }}
                </h2>

                <form wire:submit="save" class="space-y-4">
                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Topik</label>
                        <select wire:model="topic_id"
                            class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#F0F6FF; border-color:{{ $errors->has('topic_id') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                            <option value="">-- Pilih Topik --</option>
                            @foreach ($topics as $topic)
                                <option value="{{ $topic->id }}">{{ $topic->title }}</option>
                            @endforeach
                        </select>
                        @error('topic_id') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Judul Materi</label>
                        <input type="text" wire:model="title"
                            class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#F0F6FF; border-color:{{ $errors->has('title') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                        @error('title') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">
                            File PDF {{ $editingId ? '(kosongkan jika tidak ingin ganti)' : '' }}
                        </label>
                        <div class="rounded-xl border border-dashed px-3.5 py-3" style="background:#F0F6FF; border-color:#D0E2FF;">
                            <input type="file" wire:model="pdf_file" accept="application/pdf" class="w-full text-xs" style="color:#435273;">
                        </div>
                        @error('pdf_file') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                        <div wire:loading wire:target="pdf_file" class="flex items-center gap-1.5 text-xs mt-1.5" style="color:#2F6FED;">
                            <svg class="w-3.5 h-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                            </svg>
                            Mengunggah...
                        </div>
                    </div>

                    <div class="flex justify-end gap-2 pt-2">
                        <button type="button" wire:click="$set('showModal', false)"
                            class="px-4 py-2.5 text-sm font-semibold rounded-xl transition-colors" style="color:#435273;"
                            onmouseover="this.style.background='#F0F6FF'" onmouseout="this.style.background=''">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2.5 text-sm font-semibold text-white rounded-xl"
                            style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
                            <span wire:loading.remove wire:target="save">Simpan</span>
                            <span wire:loading wire:target="save">Menyimpan...</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
