<?php

namespace App\Livewire\Dosen;

use Livewire\Component;
use Illuminate\Support\Facades\Auth;

class Login extends Component
{
    public string $email = '';
    public string $password = '';

    public function login()
    {
        $this->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt(['email' => $this->email, 'password' => $this->password])) {
            $this->addError('email', 'Email atau password salah.');
            return;
        }

        if (Auth::user()->role !== 'lecturer') {
            Auth::logout();
            $this->addError('email', 'Akun ini bukan akun dosen.');
            return;
        }

        session()->regenerate();
        return redirect()->route('dosen.dashboard');
    }

    public function render()
    {
        return view('livewire.dosen.login')->layout('layouts.guest');
    }
}
