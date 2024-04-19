<?php

namespace App\Http\Middleware;

use App\Models\Stats;
use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

class loggedIn
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $validate = Validator::make($request->all(), [
            'token' => 'required',
        ]);

        if($validate->fails()){
            return response()->json(['response' => 'error', 'errors' => $validate->messages()]);
        }

        $user = User::where('token', $request->token)->first();
        if(!$user){
            return response()->json(['response' => 'Invalid token'], 403);
        }

        $request['user'] = $user;
        $request['user']['coins'] = $user->stat()->first()->coins;

        return $next($request);
    }
}
