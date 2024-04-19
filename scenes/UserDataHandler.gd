extends Node

var _GetDataRequest : HTTPRequest;
var _AuthenticationRequest : HTTPRequest;
var _LoginCheckRequest : HTTPRequest;
var _UpdateDataRequest : HTTPRequest;
var _RecordRunRequest : HTTPRequest;
var _PurchaseItem : HTTPRequest;

var _account_token;

var Coins;
var Inventory;
var BestScore;

var ItemSchema = [
	{
		name = "insert name here",
		image = "idk how this is implemented in godot",
		is_upgrade = true
	}
];


var _requestFinishedCallback = func():pass;
var _inRequest = false;

func SetOnRequestFinished(funct):
	_requestFinishedCallback = funct;

func IsInRequest():
	return _inRequest;
	
func WaitForRequestFinished():
	while _inRequest: pass;

func Register(username, password):
	Utility.proper_assert( # maybe dont do this
		_inRequest == false,
		"attempt to make request while another is in progress"
	);
	
	_account_token = "123"
	
	return true;

func Login(username, password):
	Utility.proper_assert(
		_inRequest == false,
		"attempt to make request while another is in progress"
	);
	
	_account_token = "123"
	
	return true;
	
func IsLoggedIn():
	return _account_token != null;
	
func UpdateAllData(): # updates data and sets object values
	Utility.proper_assert(
		_account_token != null,
		"user not logged in"
	);
	Utility.proper_assert(
		_inRequest == false,
		"attempt to make request while another is in progress"
	);
	
	Coins = 123;
	Inventory = [3]; # Inventory[id] == amount
	BestScore = 10;
	
	return true;

func RecordRun(coins, score):
	Utility.proper_assert(
		_account_token != null,
		"user not logged in"
	);
	Utility.proper_assert(
		_inRequest == false,
		"attempt to make request while another is in progress"
	);
	
	Coins += coins;
	BestScore = score if score > BestScore else BestScore;
	
	# ...
	
	return true;


func PurchaseItem(id):
	Utility.proper_assert(
		Inventory != null,
		"inventory not initiated"
	);
	Utility.proper_assert(
		ItemSchema[id].is_upgrade == false or Inventory[id] <= 0,
		"given item (" + str(id) + ") can't be upgraded"
	);
	Utility.proper_assert(
		_inRequest == false,
		"attempt to make request while another is in progress"
	);
	
	Inventory[id] += 1;
	
	# ...
	
	return true;

func _ready():
	UserData._GetDataRequest = $GetDataRequest;
	if(UserData._GetDataRequest == null): # W auto load
		return;
	
	UserData._AuthenticationRequest = $AuthenticationRequest;
	UserData._LoginCheckRequest = $LoginCheckRequest;
	UserData._UpdateDataRequest = $UpdateDataRequest;
	UserData._RecordRunRequest = $RecordRunRequest;
	UserData._PurchaseItem = $PurchaseItem;
	
	UserData._GetDataRequest.request_completed.connect(Completed_GetData);
	UserData._AuthenticationRequest.request_completed.connect(Completed_Authentication);
	UserData._LoginCheckRequest.request_completed.connect(Completed_LoginCheck);
	UserData._UpdateDataRequest.request_completed.connect(Completed_UpdateData);
	UserData._RecordRunRequest.request_completed.connect(Completed_RecordRun);
	UserData._PurchaseItem.request_completed.connect(Completed_PurchaseItem);

func _BasicRequest():
	_GetDataRequest.request("https://example.org");

func Completed_GetData(result, response_code, headers, body):
	pass;
	
func Completed_Authentication(result, response_code, headers, body):
	pass;

func Completed_LoginCheck(result, response_code, headers, body):
	pass;

func Completed_UpdateData(result, response_code, headers, body):
	pass;

func Completed_RecordRun(result, response_code, headers, body):
	pass;

func Completed_PurchaseItem(result, response_code, headers, body):
	pass;
