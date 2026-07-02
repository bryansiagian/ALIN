<div>
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="text-2xl font-semibold text-slate-900">Kelola Materi</h1>
            <p class="text-slate-500 text-sm mt-1">Upload materi PDF per topik untuk mahasiswa.</p>
        </div>
        <button wire:click="openCreate" class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg">
            + Upload Materi
        </button>
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
                    <th class="text-left px-5 py-3">Judul Materi</th>
                    <th class="text-left px-5 py-3">Topik</th>
                    <th class="text-left px-5 py-3">File</th>
                    <th class="text-right px-5 py-3">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($materials as $material)
                    <tr>
                        <td class="px-5 py-3 font-medium text-slate-900">{{ $material->title }}</td>
                        <td class="px-5 py-3 text-slate-600">{{ $material->topic->title ?? '-' }}</td>
                        <td class="px-5 py-3">
                            <a href="{{ $material->file_url }}" target="_blank" class="text-indigo-600 hover:underline text-xs">Lihat PDF ↗</a>
                        </td>
                        <td class="px-5 py-3 text-right space-x-2">
                            <button wire:click="openEdit({{ $material->id }})" class="text-indigo-600 hover:underline text-xs font-medium">Edit</button>
                            <button wire:click="delete({{ $material->id }})"
                                wire:confirm="Yakin mau hapus materi ini? File PDF juga akan terhapus."
                                class="text-red-600 hover:underline text-xs font-medium">Hapus</button>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-5 py-8 text-center text-slate-400 text-sm">Belum ada materi.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if ($showModal)
        <div class="fixed inset-0 bg-black/40 flex items-center justify-center z-50" wire:click.self="$set('showModal', false)">
            <div class="bg-white rounded-xl w-full max-w-md p-6">
                <h2 class="text-lg font-semibold text-slate-900 mb-4">
                    {{ $editingId ? 'Edit Materi' : 'Upload Materi' }}
                </h2>

                <form wire:submit="save" class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Topik</label>
                        <select wire:model="topic_id" class="w-full rounded-lg border-slate-300 text-sm focus:border-indigo-500 focus:ring-indigo-500">
                            <option value="">-- Pilih Topik --</option>
                            @foreach ($topics as $topic)
                                <option value="{{ $topic->id }}">{{ $topic->title }}</option>
                            @endforeach
                        </select>
                        @error('topic_id') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Judul Materi</label>
                        <input type="text" wire:model="title" class="w-full rounded-lg border-slate-300 text-sm focus:border-indigo-500 focus:ring-indigo-500">
                        @error('title') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">
                            File PDF {{ $editingId ? '(kosongkan jika tidak ingin ganti)' : '' }}
                        </label>
                        <input type="file" wire:model="pdf_file" accept="application/pdf" class="w-full text-sm">
                        @error('pdf_file') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                        <div wire:loading wire:target="pdf_file" class="text-xs text-slate-400 mt-1">Mengunggah...</div>
                    </div>

                    <div class="flex justify-end gap-2 pt-2">
                        <button type="button" wire:click="$set('showModal', false)" class="px-4 py-2 text-sm text-slate-600 hover:bg-slate-100 rounded-lg">Batal</button>
                        <button type="submit" class="px-4 py-2 text-sm bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg">
                            <span wire:loading.remove wire:target="save">Simpan</span>
                            <span wire:loading wire:target="save">Menyimpan...</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
