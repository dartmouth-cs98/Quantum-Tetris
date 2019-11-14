extends MarginContainer

var sc
var hsc
var playerName
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sc = get_node("Box/VBoxContainer/HBoxContainer2/ScoreNum")
	hsc = get_node("Box/VBoxContainer/HBoxContainer2/HighScoreNum")
	playerName = get_node("Box/VBoxContainer/HBoxContainer/Label")

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