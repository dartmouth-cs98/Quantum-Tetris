extends MarginContainer

const SCORES = [
	[0, 4, 1],
	[1, 8, 2],
	[3, 12],
	[5, 16],
	[8]
]
const LINES_CLEARED_NAMES = ["", "SINGLE", "DOUBLE", "TRIPLE", "TETRIS"]
const T_SPIN_NAMES = ["", "T-SPIN", "MINI T-SPIN"]

var level
var goal
var score
var high_score
var time
var combos

signal flash_text(text)
signal level_up
	
func new_game(start_level):
	level = start_level - 1
	goal = 0
	score = 0
	$VBC/Score.text = str(score)
	time = 0
	$VBC/Time.text = "0:00:00"
	combos = -1
	new_level()
	
func new_level():
	level += 1
	goal += 5 * level
	$VBC/Level.text = str(level)
	$VBC/Goal.text = str(goal)
	emit_signal("flash_text", "Level\n%d"%level)
	emit_signal("level_up")

func _on_Clock_timeout():
	show_time()
	
func show_time():
	var time_elapsed = OS.get_system_time_secs() - time
	var seconds = time_elapsed % 60
	var minutes = int(time_elapsed/60) % 60
	var hours = int(time_elapsed/3600)
	$VBC/Time.text = str(hours) + ":%02d"%minutes + ":%02d"%seconds

func _on_Main_piece_dropped(ds):
	score += ds
	$VBC/Score.text = str(score)

func _on_Main_piece_locked(lines, t_spin):
	var ds
	if lines or t_spin:
		var text = T_SPIN_NAMES[t_spin]
		if text:
			text += " "
		text += LINES_CLEARED_NAMES[lines]
		emit_signal("flash_text", text)
		ds = SCORES[lines][t_spin]
		goal -= ds
		$VBC/Goal.text = str(goal)
		ds *= 100
		emit_signal("flash_text", str(ds))
		score += ds
		$VBC/Score.text = str(score)
		if score > high_score:
			high_score = score
			$VBC/HighScore.text = str(high_score)
	# Combos
	if lines:
		combos += 1
		if combos > 0:
			if combos == 1:
				emit_signal("flash_text", "COMBO")
			else:
				emit_signal("flash_text", "COMBO x%d"%combos)
			ds = (20 if lines==1 else 50) * combos * level
			emit_signal("flash_text", str(ds))
			score += ds
			$VBC/Score.text = str(score)
	else:
		combos = -1
	if goal <= 0:
		new_level()
