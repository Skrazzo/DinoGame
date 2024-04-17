<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

class Stats extends Model
{
    protected $fillable = [
        'coins',
        'highscore',
        'skin_id'
    ];

    protected $appends = [
        'additional_health',
        'coin_multiplier',
        'lower_gravity_duration',
        'invincible_duration'
    ];

    protected $hidden = [
        'created_at',
        'updated_at'
    ];

    function getAdditionalHealthAttribute(){
        $start_value = 1;
        $upgrade_multiplier = 1;

        $shop = Shop::where('user_id', $this->user_id)->first();

        return $start_value + $shop->additional_health_lvl;
        
    }

    function getCoinMultiplierAttribute(){
        $start_value = 1;
        $upgrade_multiplier = 1.15;

        $shop = Shop::where('user_id', $this->user_id)->first();

        if ($shop->coin_multiplier_lvl == 0) return $start_value;
        return $start_value * $upgrade_multiplier * $shop->coin_multiplier_lvl;
    }

    function getLowerGravityDurationAttribute(){
        $start_value = 5;
        $upgrade_multiplier = 1.05;

        $shop = Shop::where('user_id', $this->user_id)->first();

        if ($shop->lower_gravity_lvl == 0) return $start_value;
        return $start_value * $upgrade_multiplier * $shop->lower_gravity_lvl;
    }

    function getInvincibleDurationAttribute(){
        $start_value = 5;
        $upgrade_multiplier = 1.05;

        $shop = Shop::where('user_id', $this->user_id)->first();

        if ($shop->invincible_duration_lvl == 0) return $start_value;
        return $start_value * $upgrade_multiplier * $shop->invincible_duration_lvl;
    }

    use HasFactory;
}
