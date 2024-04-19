<?php

namespace App\Http\Controllers;

use App\Models\Stats;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;
use Illuminate\Support\Str;

class UserController extends Controller
{
    public function save(Request $req){
        $response = array('response' => 'Data saved');
        $rules = [
            'score' => 'required|integer|min:1',
            'coins' => 'required|integer|min:1'
        ];

        $validator = Validator::make($req->all(), $rules);

        if ($validator->fails()) {
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        } else {
            //process the request
            $data = $validator->valid(); // validated data
            $stats = $req->user->stat()->first();

            if($req->score > $stats->highscore){
                $stats->highscore = $req->score;
            }

            $stats->coins += $req->coins;
            $stats->save();
            
        }

        return $response;
    }

    public function register(Request $req){
        $response = array('response' => '');
        $rules = [
            'email'     => 'required|email|unique:users,email',
            'password'  => ['required', Password::defaults()],
        ];

        $validator = Validator::make($req->all(), $rules);

        if ($validator->fails()) {
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        } else {
            //process the request
            $data = $validator->valid(); // validated data
            $user = User::create($data);
            if($user){
                // create stats record for a user
                $user->stat()->create([]);
                // create shop record for a user
                $user->shop()->create([]);

                return response()->json(['response' => 'User created successfully']);
            }
        }

        return $response;
    }

    public function login(Request $req){
        $response = array('response' => '');
        $rules = [
            'email'     => 'required|email',
            'password'  => ['required'],
        ];

        $validator = Validator::make($req->all(), $rules);

        if ($validator->fails()) {
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        } else {
            //process the request
            $data = $validator->valid(); // validated data
            
            if(Auth::attempt($data)){
                $token = Str::random(35);
                
                // saving token in db
                $user = User::where('email', $req->email)->first();
                $user->token = $token;
                $user->save();

                $response['response'] = 'Logged in succesfully!';
                $response['token'] = $token;
            }else{
                return response()->json(['response' => 'Password or email is incorrect!'], 403);
            }
        }

        return response()->json($response);
    }
}
