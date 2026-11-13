extends Node

var http := HTTPRequest.new()

var headers := [
	"Content-Type: application/json",
	"X-Master-Key: $2a$10$jGN3g6UZxX8iMPLftyWSR.gKIrlEhQcDuwoIw1s4C7VtkDeacbZL.",
	"X-Access-Key : $2a$10$Ac4H1ajT0DKsL5XRQ9toUuUWKUPZmmICR.u6nSJHJqkwnQnHqSHge",
]

func _ready():
	add_child(http)
	
func request_data() -> Dictionary:
	var error = http.request(
		"https://api.jsonbin.io/v3/b/6af70db9ac6210605a84f759/latest",
		headers
	)

	if error != OK:
		return {}

	var response = await http.request_completed

	var response_code = response[1]
	var body = response[3]

	if response_code != 200:
		return {}

	var json = JSON.parse_string(body.get_string_from_utf8())

	if json == null:
		return {}
	return json["record"]
	

func put_data(data: Dictionary) -> void:

	var url := "https://api.jsonbin.io/v3/b/6af70db9ac6210605a84f759"

	var json_body := JSON.stringify(data)

	var error := http.request(
		url,
		headers,
		HTTPClient.METHOD_PUT,
		json_body
	)

	if error != OK:
		print("PUT request error: ", error)
