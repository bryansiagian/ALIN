<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>Portal Dosen — ALIN</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
</head>
<body>
    {{ $slot }}
    @livewireScripts
</body>
</html>
