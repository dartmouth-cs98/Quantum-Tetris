extends MarginContainer

# tell functions in board.gd that speed changed
signal speed_change

#Variables for nodes
var sc
var hsc
var player_name
var speed_button

# Current score
var score = 0

# Variables for Speed node
var speeds = ["x1", "x2", "x3"]
var speed_i = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sc = get_node("Box/VBoxContainer/HBoxContainer2/ScoreNum")
	hsc = get_node("Box/VBoxContainer/HBoxContainer2/HighScoreNum")
	player_name = get_node("Box/VBoxContainer/Player_Name")
	speed_button = get_node("Box/HBoxContainer/Speed")
	
	score = 0
	sc.text = String(0)
	hsc.text = String(0)
	speed_button.text = speeds[speed_i]
	
	_load_high_score()
	
func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	var response = JSON.parse(body.get_string_from_utf8())
	hsc.text = String(response.result.hiscore)
	player_name.text =  String(response.result.username)
	

func _update_score(add):
	score += add
	sc.text = String(score)
	#update high score

func _load_high_score():
	$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/fetchPlayer?username=Guest", PoolStringArray(), false, HTTPClient.METHOD_GET)
	
func _load_player_name():
	#get  name from server
	pass

## _on_Speed_pressed()
# Emit signal to tell board.gd that speed changed
# Change the speed
func _on_Button_pressed():
	speed_i = wrapi(speed_i+1, 0, speeds.size())
	speed_button.text = speeds[speed_i]
	emit_signal("speed_change")
	
func _on_board_game_over():
	 # Convert data to json string:
	if (score>int(hsc.text)):
		var query = JSON.print({"username": "Guest", "hiscore" : int(score)})
		var headers = ["Content-Type: application/json"]
		# Add 'Content-Type' header:
		$HTTPRequest.request("https://q-tetris-backend.herokuapp.com/api/updateHiscore",  headers, false, HTTPClient.METHOD_PUT, query)
	
