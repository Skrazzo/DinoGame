#class_name UserData;

var _account_token = null;

var _coins = null;
var _inventory = null;
var _best_score = null;

func Register(username, password):
	_account_token = "123"
	return true;

func Login(username, password):
	_account_token = "123"
	return true;
	
func IsLoggedIn():
	return _account_token != null;
	
func UpdateAllData(): # updates data and sets object values
	assert(_account_token != null);
	
	_coins = 123;
	_inventory = [3,4,1];
	_best_score = 10;
	
	return true;

func GetUserData(): # fetches values from object
	assert(_coins != null && _inventory != null && _best_score != null)
	
	return {
		"coins": _coins,
		"inventory": _inventory,
		"best_score": _best_score
	};

func RecordRun(coins, score):
	assert(_account_token != null);
	
	_coins += coins;
	_best_score = score if score > _best_score else _best_score;
	
	# ...
	
	return true;


func PurchaseItem(id):
	assert(_inventory != null);
	assert(_inventory[id].is_upgrade == false or _inventory[id].amount <= 0); # if not an upgrade and already bought, throw error
	
	_inventory[id].amount += 1;
	
	# ...
	
	return true;
