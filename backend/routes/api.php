<?php

use App\Http\Controllers\ShopController;
use App\Http\Controllers\StatsController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\loggedIn;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request;
})->middleware(loggedIn::class);


Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

Route::middleware(loggedIn::class)->group(function () {
    // shop
    Route::prefix('/shop')->group(function () {
        Route::get('/', [ShopController::class, 'get_shop']);
        Route::post('/upgrade', [ShopController::class, 'upgrade']);
        Route::post('/skin', [ShopController::class, 'skin']);
        Route::post('/equip', [ShopController::class, 'equip']);
    });

    // save data
    Route::post('/save', [UserController::class, 'save']);

    // stats
    Route::prefix('/stats')->group(function () {
        Route::get('/', [StatsController::class, 'get_stats']);
    });
});
