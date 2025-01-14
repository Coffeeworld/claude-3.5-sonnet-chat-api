@tool
extends Control

const APIEndpoint = "https://api.anthropic.com/v1/messages"

@onready var input_field: TextEdit = %Input
@onready var http_request: HTTPRequest = %HTTPRequest
@onready var send_button: Button = %SendButton
@onready var clear_button: Button = %ClearButton
@onready var status_label: Label = %StatusLabel
@onready var output_field: TextEdit = %Output


func _on_clear_pressed():
	input_field.text = ""
	output_field.text = ""
	status_label.text = ""

func _on_send_pressed():
	var api_key = ProjectSettings.get_setting("plugins/claude_api/api_key")
	if api_key.strip_edges().is_empty():
		status_label.text = "Error: API key not configured"
		return
		
	status_label.text = "Sending request..."
	input_field.editable = false

	var headers = [
		"x-api-key: %s" % api_key,
		"Content-Type: application/json",
		"anthropic-version: 2023-06-01"
	]

	var message = input_field.text

	var body = JSON.stringify({
		"messages": [ {"role": "user", "content": message}],
		"model": "claude-3-5-sonnet-20241022",
		"max_tokens": 1024
	})

	var error = http_request.request(APIEndpoint, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		status_label.text = "Error: Failed to send request"
		input_field.editable = true
	
func _on_request_completed(result, response_code, headers, body):
	input_field.editable = true
	
	if result != HTTPRequest.RESULT_SUCCESS:
		status_label.text = "Error: Failed to connect to API"
		return
		
	if response_code != 200:
		status_label.text = "Error: API returned code %d" % response_code
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json != null and json.has("content"):
		status_label.text = "Response received"
		output_field.text = json.content[0].text
	else:
		status_label.text = "Error: Invalid response format"
