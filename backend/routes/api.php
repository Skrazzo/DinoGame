<?php

use App\Http\Controllers\UserController;
use App\Http\Middleware\loggedIn;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

Route::get('/', function () {
    return response('Hello world');
})->middleware(loggedIn::class);