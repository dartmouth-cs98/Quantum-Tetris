extends MarginContainer

const SCORES = [
	{"": 0, "MINI T-SPIN": 1, "T-SPIN": 4},
	{"": 1, "MINI T-SPIN": 2, "T-SPIN": 8},
	{"": 3, "T-SPIN": 12},
	{"": 5, "T-SPIN": 16},
	{"": 8}
]
const LINES_CLEARED_NAMES = ["", "SINGLE", "DOUBLE", "TRIPLE", "TETRIS"]
const password = "TETRIS 3000"

var level
var goal
var score
var high_score
var time
var combos

signal level_up(level)
signal flash_text(text)

func _ready():
	load_user_data()
	
func load_user_data():
	var save_game = File.new()
	if not save_game.file_exists("user://data.save"):
		high_score = 0
	else:
		save_game.open_encrypted_with_pass("user://data.save", File.READ, password)
		high_score = int(save_game.get_line())
		$VBC/HighScore.text = str(high_score)
		save_game.close()
	
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
	emit_signal("level_up", level)

func _on_Clock_timeout():
	show_time()
	
func show_time():
	var time_elapsed = OS.get_system_time_secs() - time
	var seconds = time_elapsed % 60
	var minutes = int(time_elapsed/60) % 60
	var hours = int(time_elapsed/3600)
	$VBC/Time.text = str(hours) + ":%02d"%minutes + ":%02d"%seconds

func piece_dropped(ds):
	score += ds
	$VBC/Score.text = str(score)

func piece_locked(lines, t_spin):
	var ds
	if lines or t_spin:
		if lines and t_spin:
			emit_signal("flash_text", t_spin + " " + LINES_CLEARED_NAMES[lines])
		elif lines:
			emit_signal("flash_text", LINES_CLEARED_NAMES[lines])
		elif t_spin:
			emit_signal("flash_text", t_spin)
		goal -= SCORES[lines][""]
		$VBC/Goal.text = str(goal)
		ds = 100 * level * SCORES[lines][t_spin]
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
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			save_user_data()

func save_user_data():
	var save_game = File.new()
	save_game.open_encrypted_with_pass("user://data.save", File.WRITE, password)
	save_game.store_line(str(high_score))
	save_game.close()