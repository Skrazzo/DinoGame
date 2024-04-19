<?php

namespace App\Http\Controllers;

use App\Models\Skins;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ShopController extends Controller
{
    private function calculate_multiplier_cost($lvl){
        $price_multiplier = 1.25;
        $start_price = 10;

        if($lvl == 0) return $start_price;
        return $start_price * $lvl * $price_multiplier;
    }

    private function calculate_duration_cost($lvl){
        $price_multiplier = 2;
        $start_price = 10;

        if($lvl == 0) return $start_price;
        return $start_price * $lvl * $price_multiplier;
    }

    private function calculate_health_cost($lvl){
        $price_multiplier = 1.2;
        $start_price = 75;

        if($lvl == 0) return $start_price;
        return $start_price * $lvl * $price_multiplier;
    }

    public function get_shop(Request $req){
        $shop = $req->user->shop()->first();

        $rtn = [
            'coin_multiplier' => [
                'lvl' => $shop->coin_multiplier_lvl,
                'price' => $this->calculate_multiplier_cost($shop->coin_multiplier_lvl)

            ],
            'lower_gravity_lvl' => [
                'lvl' => $shop->lower_gravity_lvl,
                'price' => $this->calculate_duration_cost($shop->lower_gravity_lvl)
            ],
            'invincible_duration_lvl' => [
                'lvl' => $shop->invincible_duration_lvl,
                'price' => $this->calculate_duration_cost($shop->invincible_duration_lvl)
            ],
            'additional_health_lvl' => [
                'lvl' => $shop->additional_health_lvl,
                'price' => $this->calculate_health_cost($shop->additional_health_lvl)
            ],
            'unloacked_skins' => $shop->unlocked_skins,
            'user' => $req->user,
        ];

        
        // return response()->json($shop);
        return response()->json($rtn);
    }

    private function spend($cost, $req){
        $a = $req->user->stat()->first();
        $a->coins -= $cost;
        $a->save();
    }

    public function upgrade(Request $req){
        $response = array('response' => '');
        $rules = [
            'upgrade_name' => 'required|in:coin_multiplier,lower_gravity_duration,invincible_duration,additional_health',
        ];
        
        $validator = Validator::make($req->all(), $rules);
        if ($validator->fails()) {
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        } else {
            //process the request
            $data = $validator->valid(); // validated data
            $shop = $req->user->shop()->first();
            
            // if user can buy the upgrade
            switch($data['upgrade_name']){
                case 'coin_multiplier':
                    $price = $this->calculate_multiplier_cost($shop->coin_multiplier_lvl);
                    if ($req->user->coins < $price){
                        $response['response'] = 'Not enough coins';
                    }else{
                        $value = $shop->coin_multiplier_lvl += 1;
                        $shop->save();
                        $response['response'] = 'Upgraded to level '. $value;
                        $this->spend($price, $req);
                    }
                    break;
                case 'lower_gravity_duration':
                    $price = $this->calculate_duration_cost($shop->lower_gravity_lvl);
                    if ($req->user->coins < $price){
                        $response['response'] = 'Not enough coins';
                    }else{
                        $value = $shop->lower_gravity_lvl += 1;
                        $shop->save();
                        $response['response'] = 'Upgraded to level '. $value;
                        $this->spend($price, $req);
                    }
                    break;
                case 'invincible_duration':
                    $price = $this->calculate_duration_cost($shop->invincible_duration_lvl);
                    if ($req->user->coins < $price){
                        $response['response'] = 'Not enough coins';
                    }else{
                        $value = $shop->invincible_duration_lvl += 1;
                        $shop->save();
                        $response['response'] = 'Upgraded to level '. $value;
                        $this->spend($price, $req);
                    }
                    break;
                case 'additional_health':
                    $price = $this->calculate_health_cost($shop->additional_health_lvl);
                    if ($req->user->coins < $price){
                        $response['response'] = 'Not enough coins';
                    }else{
                        $value = $shop->additional_health_lvl += 1;
                        $shop->save();
                        $response['response'] = 'Upgraded to level '. $value;
                        $this->spend($price, $req);
                    }
                    break;
            }
        }

        return $response;
    }

    public function skin(Request $req){
        $response = array('response' => '');
        $rules = [
            'skin_name' => 'required|exists:skins,name',
        ];
        
        $validator = Validator::make($req->all(), $rules);
        if($validator->fails()){
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        }else{
            //process the request
            $data = $validator->valid(); // validated data
            $skin = Skins::where('name', $data['skin_name'])->first();
            $shop = $req->user->shop()->first();

            if(!in_array($data['skin_name'], $shop->unlocked_skins)){

                if($req->user->coins < $skin->price){
                    $response['response'] = 'Not enough coins';
                }else{
                    $shop->unlocked_skins = array_merge($shop->unlocked_skins,[$skin->name]);
                    $shop->save();
                    $this->spend($skin->price, $req);

                    $response['response'] = $data['skin_name'] . ' has been bought';
                }
            }else{
                $response['response'] = 'You already have the skin';
            }

        }


        return $response;
    }

    public function equip(Request $req){
        $response = array('response' => '');
        $rules = [
            'skin_name' => 'required|exists:skins,name',
        ];
        
        $validator = Validator::make($req->all(), $rules);
        if($validator->fails()){
            $response['response'] = $validator->messages();
            return response()->json($response, 403);
        }else{
            //process the request
            $data = $validator->valid(); // validated data
            $skin = Skins::where('name', $data['skin_name'])->first();
            $shop = $req->user->shop()->first();

            if(in_array($skin->name, $shop->unlocked_skins)){
                $stats = $req->user->stat()->first();
                $stats->skin = $skin->name;
                if($stats->save()){
                    $response['response'] = $skin->name . ' is now equipped';
                }
            }else{
                $response['response'] = $skin->name . ' is not unlocked yet';
            }
        }
        return $response;
    }

    
}
