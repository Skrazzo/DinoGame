extends Node

class_name ActualHTTPClient;

var client: HTTPClient;
const base_headers: PackedStringArray = [
	"User-Agent: Pirulo/1.0 (Godot)",
	"Accept: */*"
];

func _init():
	client = HTTPClient.new() # Create the Client.

const _methods: Dictionary = {
	"GET"  : HTTPClient.METHOD_GET,
	"POST" : HTTPClient.METHOD_POST
};

func Request(method: String, url: String, body: Dictionary = {}, headers: PackedStringArray = [], content_type: String = ""):
	headers.append_array(base_headers);			
	
	var raw_body: String = "";
	if(method != "GET" and !body.is_empty()):
		if(content_type == ""):
			content_type = "application/json";
		headers.append("Content_Type: " + content_type);
		
		if(content_type == "application/x-www-form-urlencoded"):
			for key in body:
				raw_body += "{0}={1}&".format([key.uri_encode(), body[key].uri_encode()]);
			
			raw_body = raw_body.trim_suffix("&");
		elif(content_type == "application/json"):
			raw_body = JSON.stringify(body);
		else:
			Utility.proper_assert(false, "Unknown content type");
	
	var url_start: int;
	var port: int;
	
	if(url.begins_with("http://")):
		url_start = "http://".length();
		port = 80;
	elif(url.begins_with("https://")):
		url_start = "https://".length();
		port = 443;
	else:
		url_start = 0;
		port = 80;

	var port_start: int = url.find(":", url_start);
	if(port_start != -1):
		var port_end: int = url.find("/", port_start);
		if(port_end == -1): port_end = url.length();
		port = int(Utility.proper_substring(url, port_start + 1, port_end));
		url = Utility.proper_substring(url, 0, port_start) + Utility.proper_substring(url, port_end);

	var endpointI: int = url.find("/", url_start);
	if(endpointI == -1):
		endpointI = url.length();
		url += "/";

	var url_host: String = Utility.proper_substring(url, url_start, endpointI); 
	var url_endpoint: String = Utility.proper_substring(url, endpointI);
	
	#print(url);
	#print(port);
	#print(url_host);
	#print(url_endpoint);
	#print(_methods[method]);
	#print(raw_body);
	
	Utility.proper_assert(
		client.connect_to_host(url_host, port) == OK,
		"Failed to connect to host"
	);

	while client.get_status() == HTTPClient.STATUS_CONNECTING or client.get_status() == HTTPClient.STATUS_RESOLVING:
		client.poll();

	Utility.proper_assert(
		client.get_status() == HTTPClient.STATUS_CONNECTED,
		"Client tried to connect to host but failed"
	);
	
	Utility.proper_assert(
		client.request(_methods[method], url_endpoint, headers, raw_body) == OK,
		"Request failed"
	);

	while client.get_status() == HTTPClient.STATUS_REQUESTING:
		client.poll();

	Utility.proper_assert(
		client.get_status() == HTTPClient.STATUS_BODY or client.get_status() == HTTPClient.STATUS_CONNECTED,
		"Request didn't finish properly"
	);
	
	if client.has_response():		
		var rb = PackedByteArray() # Array that will hold the data.
		while client.get_status() == HTTPClient.STATUS_BODY:
			client.poll();
			var chunk := client.read_response_body_chunk();
			if chunk.size() == 0:
				pass; #await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.

		return {
			"response": rb.get_string_from_ascii(),
			"headers" : client.get_response_headers_as_dictionary()
		};
