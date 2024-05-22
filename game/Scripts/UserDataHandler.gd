extends Node

var _http_client: HTTPRequestWrapper;

var _account_token;

# godot is retarded and doesnt let you null typed variables
var Coins; # int
var BestScore; # int
var Upgrades; # dictionary
var UnlockedSkins; # array
var EquippedSkin; #string

func _get_response(response_object) -> Dictionary:
	Utility.proper_assert(typeof(response_object) == TYPE_ARRAY, "Failed to create request. Output code: {0}".format([response_object]), 1)
	
	var json = JSON.new();
	var received_data: String = response_object[3].get_string_from_utf8();
	Utility.proper_assert(json.parse(received_data) == OK, "Failed to decode received data. Response object: {0}".format([Utility.truncate_string(received_data, 200)]), 1);
	return json.data;

func Register(username: String, password: String):
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/register/",
	{
		"email": username,
		"password": password
	}));
	
	if(response.has("token")):	
		_account_token = response.token;
		return [true];
	else:
		return [false, response];
	

func Login(username: String, password: String):	
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/login/",
	{
		"email": username,
		"password": password
	}));
	
	if(response.has("token")):	
		_account_token = response.token;
		return [true];
	else:
		return [false, response];
	
func IsLoggedIn() -> bool:
	return _account_token != null;
	
func UpdateAllData() -> bool: # updates data and sets object values
	Utility.proper_assert(
		_account_token != null,
		"user not logged in"
	);
	
	var response: Dictionary;	
	response = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_GET, "http://127.0.0.1:8000/api/stats/",
	{
		"token": _account_token
	}));
	
	Coins = response.coins;
	BestScore = response.highscore;
	EquippedSkin = response.skin;
	
	response = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_GET, "http://127.0.0.1:8000/api/shop/",
	{
		"token": _account_token
	}));
	
	Upgrades = {
		"coin_multiplier": response.coin_multiplier,
		"low_gravity": response.lower_gravity_lvl,
		"invincibility": response.invincible_duration_lvl,
		"additional_health": response.additional_health_lvl
	};
	UnlockedSkins = response.unloacked_skins;
	
	return true;

func RecordRun(coins: int, score: int) -> bool:
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/save/",
	{
		"token": _account_token,
		"coins": coins,
		"score": score
	}));
	
	Utility.proper_assert(str(response.response) == "Data saved", "Failed to record run, reason: {0}".format([str(response.response)]));
	
	return true;

 # start price * next lvl * price multiplier
func _next_mult_cost(cur_lvl: int):
	return 10 * (cur_lvl + 1) * 1.25;
	
func _next_duration_cost(cur_lvl: int):
	return 10 * (cur_lvl + 1) * 2;
	
func _next_health_cost(cur_lvl: int):
	return 75 * (cur_lvl + 1) * 1.2;

var _upgrade_schema: Dictionary = {
	"coin_multiplier": "coin_multiplier",
	"low_gravity": "lower_gravity_duration",
	"invincibility": "invincible_duration",
	"additional_health": "additional_health"
}

var _skin_schema: Dictionary = {
	"Nico": 100,
	"Olaf": 100,
	"Sena": 100,
	"Tard": 100
};

func _PurchaseUpgrade(name: String) -> void:
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/shop/upgrade/",
	{
		"token": _account_token,
		"upgrade_name": _upgrade_schema[name]
	}));
	
	Utility.proper_assert(str(response.response) == "Upgraded to level " + str(Upgrades[name].lvl), "Failed to purchase upgrade, reason: {0}".format([str(response.response)]));

func _PurchaseSkin(name: String) -> void:
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/shop/skin/",
	{
		"token": _account_token,
		"skin_name": name
	}));
	
	Utility.proper_assert(str(response.response) == (name + " has been bought"), "Failed to purchase skin, reason: {0}".format([str(response.response)]));

func PurchaseItem(name: String) -> bool:	
	Utility.proper_assert(
		_account_token != null,
		"user not logged in"
	);
		
	Utility.proper_assert( # this can be removed if neccecary
		Upgrades != null,
		"inventory not initiated"
	);
	
	if(_upgrade_schema.has(name)):
		match name:
			"coin_multiplier":
				if(Coins < Upgrades.coin_multiplier.price):
					return false;
				Coins -= Upgrades.coin_multiplier.price;
				Upgrades.coin_multiplier.price = _next_mult_cost(Upgrades.coin_multiplier.lvl);
				Upgrades.coin_multiplier.lvl += 1;
			"low_gravity": 
				if(Coins < Upgrades.low_gravity.price):
					return false;
				Coins -= Upgrades.low_gravity.price;
				Upgrades.low_gravity.price = _next_duration_cost(Upgrades.low_gravity.lvl);
				Upgrades.low_gravity.lvl += 1;
			"invincibility": 
				if(Coins < Upgrades.invincibility.price):
					return false;
				Coins -= Upgrades.invincibility.price;
				Upgrades.invincibility.price = _next_duration_cost(Upgrades.invincibility.lvl);
				Upgrades.invincibility.lvl += 1;
			"additional_health":
				if(Coins < Upgrades.additional_health.price):
					return false;
				Coins -= Upgrades.additional_health.price;
				Upgrades.additional_health.price = _next_health_cost(Upgrades.additional_health.lvl);
				Upgrades.additional_health.lvl += 1;
				
		await _PurchaseUpgrade(name);
		return true;
		
	Utility.proper_assert(_skin_schema.has(name), "Invalid name ({0}) given to PurchaseItem".format([name]));	
	Utility.proper_assert(UnlockedSkins.find(name) == -1, "{0} has already been purchased".format([name]));
	if(Coins < _skin_schema[name]):
		return false;	
	Coins -= _skin_schema[name];
	UnlockedSkins.append(name);
	
	await _PurchaseSkin(name);
	return true;

func EquipSkin(name: String) -> bool:
	Utility.proper_assert(
		_account_token != null,
		"user not logged in"
	);
	
	Utility.proper_assert( # this can be removed if neccecary
		EquippedSkin != null,
		"EquippedSkin not initiated"
	);
	
	
	Utility.proper_assert(
		_skin_schema.has(name),
		"Invalid name given to EquipSkin ({0})".format([name])
	);
	
	var response: Dictionary = _get_response(await _http_client.RequestSync(HTTPClient.METHOD_POST, "http://127.0.0.1:8000/api/shop/equip/",
	{
		"token": _account_token,
		"skin_name": name
	}));
	
	Utility.proper_assert(
		str(response.response) == (name + " is now equipped"),
		"Failed to equip skin, reason: {0}".format([str(response.response)])
	);
	
	EquippedSkin = name;
	
	return true;

func _ready():
	var http_request_obj: HTTPRequest = HTTPRequest.new();
	add_child(http_request_obj);	
	_http_client = HTTPRequestWrapper.new(http_request_obj);
	
	print("Login ", await Login("12sdfgsdfgsd3ffg3@gg.gg", "245v6254f6v254v6"))
	print("Record ", await RecordRun(100, 10))
	print("Update Data ", await UpdateAllData())
	print("Purchase ", await PurchaseItem("additional_health"))
	await EquipSkin("Olaf");
	print("Data:")
	print("\tCoins: {}\n\tBestScore: {}\n\tUpgrades: {}\n\tUnlockedSkins: {}\n\tEquippedSkin: {}"
		.format([Coins, BestScore, str(Upgrades), str(UnlockedSkins), EquippedSkin], "{}"))
