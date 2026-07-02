<div>
    {{-- Header --}}
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="font-['Space_Grotesk'] text-2xl font-bold" style="color:#0F2D6B;">Kelola Topik</h1>
            <p class="text-sm mt-1" style="color:#7C8DB5;">Topik jadi dasar pengelompokan materi, bank soal, dan kuis.</p>
        </div>
        <button wire:click="openCreate"
            class="flex items-center gap-1.5 text-white text-sm font-semibold px-4 py-2.5 rounded-xl transition-transform hover:-translate-y-0.5"
            style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
            </svg>
            Tambah Topik
        </button>
    </div>

    {{-- Flash messages --}}
    @if (session('success'))
        <div class="flex items-center gap-2 mb-4 text-sm px-4 py-2.5 rounded-xl"
            style="background:#ECFDF5; border:1px solid #A7F3D0; color:#047857;">
            <svg class="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="flex items-center gap-2 mb-4 text-sm px-4 py-2.5 rounded-xl"
            style="background:#FFEBEE; border:1px solid #FFCDD2; color:#B71C1C;">
            <svg class="w-4 h-4 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
            </svg>
            {{ session('error') }}
        </div>
    @endif

    {{-- Table card --}}
    <div class="bg-white rounded-2xl overflow-hidden"
        style="border:1px solid #E3EBFA; box-shadow: 0 4px 16px -8px rgba(75,142,255,0.15);">
        <table class="w-full text-sm">
            <thead style="background:#F5F8FC;">
                <tr>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Judul</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Materi</th>
                    <th class="text-left px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Status</th>
                    <th class="text-right px-5 py-3 text-[11px] font-bold uppercase tracking-wider" style="color:#7C8DB5;">Aksi</th>
                </tr>
            </thead>
            <tbody style="border-top:1px solid #E3EBFA;">
                @foreach ($topics as $topic)
                    <tr style="{{ $topic->id == 6 ? 'background:#FFFBEB;' : '' }} border-top:1px solid #F0F4FC;">
                        <td class="px-5 py-3.5">
                            <p class="font-semibold" style="color:#0F2D6B;">{{ $topic->title }}</p>
                            @if ($topic->id == 6)
                                <span class="inline-flex items-center gap-1 text-xs font-medium mt-0.5" style="color:#B45309;">
                                    🔒 Placement Test — terkunci
                                </span>
                            @else
                                <p class="text-xs mt-0.5" style="color:#8B98B8;">{{ Str::limit($topic->description, 60) }}</p>
                            @endif
                        </td>
                        <td class="px-5 py-3.5" style="color:#435273;">{{ $topic->materials_count }}</td>
                        <td class="px-5 py-3.5">
                            @if ($topic->is_active)
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#ECFDF5; color:#047857;">Aktif</span>
                            @else
                                <span class="text-xs font-semibold px-2.5 py-1 rounded-full" style="background:#F1F5F9; color:#64748B;">Nonaktif</span>
                            @endif
                        </td>
                        <td class="px-5 py-3.5 text-right space-x-3">
                            @if ($topic->id != 6)
                                <button wire:click="openEdit({{ $topic->id }})"
                                    class="text-xs font-semibold transition-colors" style="color:#2F6FED;"
                                    onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                    Edit
                                </button>
                                <button wire:click="delete({{ $topic->id }})"
                                    wire:confirm="Yakin mau hapus topik ini?"
                                    class="text-xs font-semibold transition-colors" style="color:#E53935;"
                                    onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                                    Hapus
                                </button>
                            @endif
                        </td>
                    </tr>
                @endforeach

                @if ($topics->isEmpty())
                    <tr>
                        <td colspan="4" class="px-5 py-12 text-center text-sm" style="color:#A9B6D6;">
                            Belum ada topik. Klik "Tambah Topik" untuk membuat yang pertama.
                        </td>
                    </tr>
                @endif
            </tbody>
        </table>
    </div>

    {{-- Modal Create/Edit --}}
    @if ($showModal)
        <div class="fixed inset-0 flex items-center justify-center z-50 px-4" style="background:rgba(15,45,107,0.35);" wire:click.self="$set('showModal', false)">
            <div class="bg-white rounded-2xl w-full max-w-md p-6" style="box-shadow: 0 20px 48px -12px rgba(15,45,107,0.35);">
                <h2 class="font-['Space_Grotesk'] text-lg font-bold mb-5" style="color:#0F2D6B;">
                    {{ $editingId ? 'Edit Topik' : 'Tambah Topik' }}
                </h2>

                <form wire:submit="save" class="space-y-4">
                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Judul Topik</label>
                        <input type="text" wire:model="title"
                            class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#F0F6FF; border-color:{{ $errors->has('title') ? '#FFCDD2' : '#D0E2FF' }}; color:#0F2D6B; --tw-ring-color:#4B8EFF33;">
                        @error('title') <p class="text-xs mt-1.5" style="color:#E53935;">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-xs font-semibold mb-1.5" style="color:#0F2D6B;">Deskripsi</label>
                        <textarea wire:model="description" rows="3"
                            class="w-full rounded-xl border pl-3.5 pr-3.5 py-2.5 text-sm font-medium transition-colors focus:outline-none focus:ring-2"
                            style="background:#F0F6FF; border-color:#D0E2FF; color:#0F2D6B; --tw-ring-color:#4B8EFF33;"></textarea>
                    </div>

                    <label class="flex items-center gap-2.5 text-sm font-medium cursor-pointer" style="color:#435273;">
                        <input type="checkbox" wire:model="is_active"
                            class="w-4 h-4 rounded" style="border-color:#D0E2FF; accent-color:#2F6FED;">
                        Tampilkan ke mahasiswa (aktif)
                    </label>

                    <div class="flex justify-end gap-2 pt-2">
                        <button type="button" wire:click="$set('showModal', false)"
                            class="px-4 py-2.5 text-sm font-semibold rounded-xl transition-colors" style="color:#435273;"
                            onmouseover="this.style.background='#F0F6FF'" onmouseout="this.style.background=''">
                            Batal
                        </button>
                        <button type="submit"
                            class="px-4 py-2.5 text-sm font-semibold text-white rounded-xl"
                            style="background: linear-gradient(135deg, #4B8EFF, #1A5FD4); box-shadow: 0 8px 18px -6px rgba(26,95,212,0.45);">
                            Simpan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
