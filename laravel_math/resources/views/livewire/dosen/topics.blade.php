<div>
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="text-2xl font-semibold text-slate-900">Kelola Topik</h1>
            <p class="text-slate-500 text-sm mt-1">Topik jadi dasar pengelompokan materi, bank soal, dan kuis.</p>
        </div>
        <button wire:click="openCreate" class="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-2 rounded-lg">
            + Tambah Topik
        </button>
    </div>

    @if (session('success'))
        <div class="mb-4 bg-emerald-50 text-emerald-700 text-sm px-4 py-2.5 rounded-lg border border-emerald-200">
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="mb-4 bg-red-50 text-red-700 text-sm px-4 py-2.5 rounded-lg border border-red-200">
            {{ session('error') }}
        </div>
    @endif

    <div class="bg-white rounded-xl border border-slate-200 overflow-hidden">
        <table class="w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase">
                <tr>
                    <th class="text-left px-5 py-3">Judul</th>
                    <th class="text-left px-5 py-3">Materi</th>
                    <th class="text-left px-5 py-3">Status</th>
                    <th class="text-right px-5 py-3">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @foreach ($topics as $topic)
                    <tr class="{{ $topic->id == 6 ? 'bg-amber-50/50' : '' }}">
                        <td class="px-5 py-3">
                            <p class="font-medium text-slate-900">{{ $topic->title }}</p>
                            @if ($topic->id == 6)
                                <span class="text-xs text-amber-600">🔒 Placement Test — terkunci</span>
                            @else
                                <p class="text-xs text-slate-500">{{ Str::limit($topic->description, 60) }}</p>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-slate-600">{{ $topic->materials_count }}</td>
                        <td class="px-5 py-3">
                            @if ($topic->is_active)
                                <span class="text-xs bg-emerald-100 text-emerald-700 px-2 py-1 rounded-full">Aktif</span>
                            @else
                                <span class="text-xs bg-slate-100 text-slate-500 px-2 py-1 rounded-full">Nonaktif</span>
                            @endif
                        </td>
                        <td class="px-5 py-3 text-right space-x-2">
                            @if ($topic->id != 6)
                                <button wire:click="openEdit({{ $topic->id }})" class="text-indigo-600 hover:underline text-xs font-medium">Edit</button>
                                <button wire:click="delete({{ $topic->id }})"
                                    wire:confirm="Yakin mau hapus topik ini?"
                                    class="text-red-600 hover:underline text-xs font-medium">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    {{-- Modal Create/Edit --}}
    @if ($showModal)
        <div class="fixed inset-0 bg-black/40 flex items-center justify-center z-50" wire:click.self="$set('showModal', false)">
            <div class="bg-white rounded-xl w-full max-w-md p-6">
                <h2 class="text-lg font-semibold text-slate-900 mb-4">
                    {{ $editingId ? 'Edit Topik' : 'Tambah Topik' }}
                </h2>

                <form wire:submit="save" class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Judul Topik</label>
                        <input type="text" wire:model="title" class="w-full rounded-lg border-slate-300 text-sm focus:border-indigo-500 focus:ring-indigo-500">
                        @error('title') <p class="text-xs text-red-600 mt-1">{{ $message }}</p> @enderror
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Deskripsi</label>
                        <textarea wire:model="description" rows="3" class="w-full rounded-lg border-slate-300 text-sm focus:border-indigo-500 focus:ring-indigo-500"></textarea>
                    </div>

                    <label class="flex items-center gap-2 text-sm text-slate-700">
                        <input type="checkbox" wire:model="is_active" class="rounded border-slate-300 text-indigo-600">
                        Tampilkan ke mahasiswa (aktif)
                    </label>

                    <div class="flex justify-end gap-2 pt-2">
                        <button type="button" wire:click="$set('showModal', false)" class="px-4 py-2 text-sm text-slate-600 hover:bg-slate-100 rounded-lg">Batal</button>
                        <button type="submit" class="px-4 py-2 text-sm bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    @endif
</div>
