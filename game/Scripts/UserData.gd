#extends Node
#
#var _http_client: ActualHTTPClient;
#var _account_token: String;
#
#var Coins: int;
#var Inventory: Array;
#var BestScore: int;
#
#
#func Register(email, password):
	#var response = await _http_client.Request("POST", "127.0.0.1:8000/api/register",
		#{
			#"email": email,
			#"password": password
		#}
	#);
	#
	#if(response == null):
		#return false;
	#
	#response = JSON.parse_string(response);
	#if(not "token" in response):
		#return false;
		#
	#_account_token = response.token;
	#if(_account_token == null):
		#return false;
	#
	#return true;
#
#func Login(email, password):	
	#var response = (await _http_client.Request("POST", "localhost:8000/api/login",
		#{
			#"email": email,
			#"password": password
		#}
	#)).response;
	#
	#if(response == null):
		#return false;
		#
	#response = JSON.parse_string(response);
	#if(not "token" in response):
		#return false;
		#
	#_account_token = response.token;
	#if(_account_token == null):
		#return false;
	#
	#return true;
#
#func RecordRun(coins, score):
	#Utility.proper_assert(
		#_account_token != null,
		#"user not logged in"
	#);
	#
	#Coins += coins;
	#BestScore = score if score > BestScore else BestScore;
	#
	## ...
	#
	#return true;
#
#
#func PurchaseItem(id):
	#Utility.proper_assert(
		#Inventory != null,
		#"inventory not initiated"
	#);
	#
	#Inventory[id] += 1;
	#
	## ...
	#
	#return true;
#
#func _ready():
	#_http_client = ActualHTTPClient.new();
	#print(str(await Login("test@test.com", "password")));
	#print(str(_account_token))
