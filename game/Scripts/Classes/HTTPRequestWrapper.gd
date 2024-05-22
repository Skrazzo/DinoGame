extends Node

class_name HTTPRequestWrapper;

var BaseObject: HTTPRequest;
var Callback: Callable;
var InRequest: bool = false;

const _base_headers: Dictionary = {
	"User-Agent": "Pirulo/1.0 (Godot)",
	"Accept": "*/*"
};

func _init(object, callback=func(u,c,m,r):pass):
	BaseObject = object;
	Callback = callback
	BaseObject.request_completed.connect(_on_completed);

func Request(method: HTTPClient.Method, url: String, body: Dictionary = {}, headers: Dictionary = {}, content_type: String = "application/json"):
	headers.merge(_base_headers);
	
	var raw_body: String = "";
	if(!body.is_empty()):
		headers["Content_Type"] = content_type;
		
		if(content_type == "application/x-www-form-urlencoded"): # this doesnt cover all possible cases, but will be enough for most
			for key in body:
				raw_body += "{0}={1}&".format([key.uri_encode(), body[key].uri_encode()]);
			
			raw_body = raw_body.trim_suffix("&");
		elif(content_type == "application/json"):
			raw_body = JSON.stringify(body);
		else:
			Utility.proper_assert(false, "Unknown content type");
	print(url);
	print(raw_body);
	var raw_headers: PackedStringArray = PackedStringArray();
	for key in headers:
		raw_headers.append("{0}: {1}".format([key, headers[key]]));
	
	var out: Error = BaseObject.request(url, raw_headers, method, raw_body);
	if(out == Error.OK):
		InRequest = true;
		
	return out
	
func RequestSync(method: HTTPClient.Method, url: String, body: Dictionary = {}, headers: Dictionary = {}, content_type: String = "application/json"):
	var code: Error = Request(method, url, body, headers, content_type);
	if(code == OK):
		return await BaseObject.request_completed;
	else:
		return code;

func _on_completed(result, response_code, headers, body):
	InRequest = false;
	Callback.call(result, response_code, headers, body);
