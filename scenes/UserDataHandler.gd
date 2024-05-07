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
		print("RM autoloaded");
		return;
	else:
		print("RM regular load")
	
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

func __init():
	var err = 0
	var http = HTTPClient.new() # Create the Client.

	err = http.connect_to_host("www.php.net", 80) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.

	# Wait until resolved and connected.
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		print("Connecting...")
		await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

	# Some headers
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]

	err = http.request(HTTPClient.METHOD_GET, "/ChangeLog-5.php", headers) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK.

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		print("Requesting...")
		await get_tree().process_frame

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

	print("response? ", http.has_response()) # Site might not have a response.

	if http.has_response():
		# If there is a response...

		headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("code: ", http.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)

		# This method works for both anyway

		var rb = PackedByteArray() # Array that will hold the data.

		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			# Get a chunk.
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.
		# Done!

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		print("Text: ", text)
