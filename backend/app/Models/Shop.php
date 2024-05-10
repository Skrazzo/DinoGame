<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    protected $fillable = [
        'user_id',
        'coin_multiplier_lvl',
        'lower_gravity_lvl',
        'invincible_duration_lvl',
        'additional_health_lvl',
        'unlocked_skins',
    ];

    protected $casts = [
        'unlocked_skins' => 'json',
    ];

    use HasFactory;
}
