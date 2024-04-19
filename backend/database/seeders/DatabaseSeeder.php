<?php

namespace Database\Seeders;

use App\Models\Skins;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        Skins::create([
            'name' => 'Nico',
            'price' => 100
        ]);

        Skins::create([
            'name' => 'Olaf',
            'price' => 100
        ]);

        Skins::create([
            'name' => 'Sena',
            'price' => 100
        ]);

        Skins::create([
            'name' => 'Tard',
            'price' => 100
        ]);
    }
}
