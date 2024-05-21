<?php

use App\Http\Controllers\StripeController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Ga8rnsdfyIpY5UXw5hJJUk265rXW64pTBLV
Route::prefix('stripe')->group(function () {
    Route::controller(StripeController::class)->group(function () {
        Route::get('/buy/{user_token}', 'buy')->name('stripe.buy');
        Route::get('/buy/cancel/{token:token}', 'cancel')->name('stripe.cancel');
        Route::get('/buy/success/{token:token}', 'success')->name('stripe.success');
    });
});