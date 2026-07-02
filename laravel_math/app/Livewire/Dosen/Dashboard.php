<?php

namespace App\Livewire\Dosen;

use Livewire\Component;

class Dashboard extends Component
{
    public function render()
    {
        return view('livewire.dosen.dashboard')->layout('layouts.dosen');
    }
}
