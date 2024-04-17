<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class StatsController extends Controller
{
    public function get_stats(Request $req){
        return response()->json($req->user->stat()->first());
    }
}
