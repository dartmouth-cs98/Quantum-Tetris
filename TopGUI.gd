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
	player_name = get_node("Box/VBoxContainer/HBoxContainer/Label")
	speed_button = get_node("Box/HBoxContainer/Speed")
	
	speed_button.text = speeds[speed_i]

func _update_score(add):
	score += add
	sc.text = String(score)
	#update high score

func _load_high_score():
	#get highscore from server
	pass
	
func _load_player_name():
	#get  name from server
	pass

func _upload_new_highscore():
	# send highscore to the server
	pass

## _on_Speed_pressed()
# Emit signal to tell board.gd that speed changed
# Change the speed
func _on_Button_pressed():
	speed_i = wrapi(speed_i+1, 0, speeds.size())
	speed_button.text = speeds[speed_i]
	emit_signal("speed_change")
	
