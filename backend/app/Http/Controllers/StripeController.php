<?php

namespace App\Http\Controllers;

use App\Models\Stripe;
use App\Models\User;
use Illuminate\Http\Request;

class StripeController extends Controller
{
    public function buy($user_token) {
        $user = User::where('token', $user_token)->first();

        if (!$user) {
            return abort(404);
        }

        $stripe = $user->stripe()->create();
        $stripe_session = Stripe::find($stripe->id)->first()->token;

        

        \Stripe\Stripe::setApiKey(config('stripe.sk'));
        $session = \Stripe\Checkout\Session::create([
            'line_items'  => [
                [
                    'price_data' => [
                        'currency'     => 'eur',
                        'product_data' => [
                            'name' => '10000 In game coins',
                        ],
                        'unit_amount'  => 4.99 * 100,
                    ],
                    'quantity'   =>  1,
                ],
            ],
            'mode'        => 'payment',
            'success_url' => route('stripe.success', $stripe_session),
            'cancel_url'  => route('stripe.cancel', $stripe_session),
        ]);

        return redirect($session->url);
    }


    public function cancel(Stripe $token) {
        $token->delete();

        return response('Payment canceled successfully');
    }

    public function success(Stripe $token) {
        // get user
        $user = User::find($token->user_id);
        
        // Update user coins
        $user_stat = $user->stat()->first();
        $user_stat->coins = $user_stat->coins + 10000;
        $user_stat->save();

        // delete stripe session
        $token->delete();
        
        return response('Successfully added 10000 in game coins to your account!');
    }
}
