extends MarginContainer

var sc
var hsc
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sc = get_node("HBoxContainer/VBoxContainer/HBoxContainer2/ScoreNum")
	hsc = get_node("HBoxContainer/VBoxContainer/HBoxContainer2/HighScoreNum")

func _update_score(add):
	score += add
	sc.text = String(score)

