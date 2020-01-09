extends WorldEnvironment

const Tetromino = preload("res://Tetrominos/Tetromino.gd")
const TetroI = preload("res://Tetrominos/TetroI.tscn")
const TetroJ = preload("res://Tetrominos/TetroJ.tscn")
const TetroL = preload("res://Tetrominos/TetroL.tscn")
const TetroO = preload("res://Tetrominos/TetroO.tscn")
const TetroS = preload("res://Tetrominos/TetroS.tscn")
const TetroT = preload("res://Tetrominos/TetroT.tscn")
const TetroZ = preload("res://Tetrominos/TetroZ.tscn")

const password = "TETRIS 3000"

const NEXT_POSITION = Vector3(13, 16, 0)
const START_POSITION = Vector3(5, 20, 0)
const HOLD_POSITION = Vector3(-5, 16, 0)

const movements = {
	"move_right": Vector3(1, 0, 0),
	"move_left": Vector3(-1, 0, 0),
	"soft_drop": Vector3(0, -1, 0)
}

var random_bag = []

var next_piece
var current_piece
var held_piece
var current_piece_held

var autoshift_action = ""

var playing = false

signal piece_dropped(score)
signal piece_locked(lines, t_spin)

func _ready():
	load_user_data()
	
func load_user_data():
	var save_game = File.new()
	if not save_game.file_exists("user://data.save"):
		$Stats.high_score = 0
	else:
		save_game.open_encrypted_with_pass("user://data.save", File.READ, password)
		$Stats.high_score = int(save_game.get_line())
		$Stats/VBC/HighScore.text = str($Stats.high_score)
		save_game.close()

func _on_Start_start(level):
	$GridMap.clear()
	if held_piece:
		remove_child(held_piece)
		held_piece = null
	current_piece_held = false
	next_piece = random_piece()
	new_piece()
	$MidiPlayer.position = 0
	$Start.visible = false
	$Stats.new_game(level)
	resume()
	
func new_piece():
	if current_piece:
		remove_child(current_piece)
	current_piece = next_piece
	current_piece.translation = START_POSITION
	current_piece.emit_trail(true)
	autoshift_action = ""
	next_piece = random_piece()
	next_piece.translation = NEXT_POSITION
	if move(movements["soft_drop"]):
		$DropTimer.start()
		$LockDelay.start()
		current_piece_held = false
	else:
		current_piece.translate(movements["soft_drop"])
		game_over()

func random_piece():
	if not random_bag:
		random_bag = [
			TetroI, TetroJ, TetroL, TetroO,
			TetroS, TetroT, TetroZ
		]
	var choice = randi() % random_bag.size()
	var piece = random_bag[choice].instance()
	random_bag.remove(choice)
	add_child(piece)
	return piece

func _on_Stats_level_up():
	$DropTimer.wait_time = pow(0.8 - (($Stats.level - 1) * 0.007), $Stats.level - 1)
	if $Stats.level > 15:
		$LockDelay.wait_time = 0.5 * pow(0.9, $Stats.level-15)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if playing:
			pause()
			$controls_ui.visible = true
		elif $controls_ui.enable_resume:
			resume()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if playing:
		for action in movements:
			if action == autoshift_action:
				if not Input.is_action_pressed(action):
					$AutoShiftDelay.stop()
					$AutoShiftTimer.stop()
					autoshift_action = ""
			else:
				if Input.is_action_pressed(action):
					autoshift_action = action
					process_autoshift_action()
					$AutoShiftTimer.stop()
					$AutoShiftDelay.start()
		if Input.is_action_just_pressed("hard_drop"):
			hard_drop()
		if Input.is_action_just_pressed("rotate_clockwise"):
			rotate(Tetromino.CLOCKWISE)
		if Input.is_action_just_pressed("rotate_counterclockwise"):
			rotate(Tetromino.COUNTERCLOCKWISE)
		if Input.is_action_just_pressed("hold"):
			hold()

func _on_AutoShiftDelay_timeout():
	if playing and autoshift_action:
		process_autoshift_action()
		$AutoShiftTimer.start()

func _on_AutoShiftTimer_timeout():
	if playing and autoshift_action:
		process_autoshift_action()

func process_autoshift_action():
	if move(movements[autoshift_action]):
		if autoshift_action == "soft_drop":
			emit_signal("piece_dropped", 1)

func hard_drop():
	var score = 0
	while move(movements["soft_drop"]):
		score += 2
	emit_signal("piece_dropped", score)
	lock()
	
func move(movement):
	if current_piece.move(movement):
		$LockDelay.start()
		return true
	else:
		return false
		
func rotate(direction):
	if current_piece.rotate(direction):
		$LockDelay.start()
		return true
	else:
		return false

func _on_DropTimer_timeout():
	move(movements["soft_drop"])

func _on_LockDelay_timeout():
	if not move(movements["soft_drop"]):
		lock()
		
func lock():
	$GridMap.lock(current_piece)
	emit_signal("piece_locked", $GridMap.clear_lines(), current_piece.t_spin)
	new_piece()

func hold():
	if not current_piece_held:
		current_piece_held = true
		var swap = current_piece
		current_piece = held_piece
		held_piece = swap
		held_piece.emit_trail(false)
		held_piece.translation = HOLD_POSITION
		if current_piece:
			current_piece.translation = START_POSITION
			current_piece.emit_trail(true)
		else:
			new_piece()
		
func resume():
	playing = true
	$DropTimer.start()
	$LockDelay.start()
	$Stats.time = OS.get_system_time_secs() - $Stats.time
	$Stats/Clock.start()
	$MidiPlayer.resume()
	$controls_ui.visible = false
	$Stats.visible = true
	$GridMap.visible = true
	$Backs.visible = true
	current_piece.visible = true
	if held_piece:
		held_piece.visible = true
	next_piece.visible = true

func pause(hide=true):
	playing = false
	$Stats.time = OS.get_system_time_secs() - $Stats.time
	if hide:
		$Stats.visible = false
		$GridMap.visible = false
		$Backs.visible = false
		current_piece.visible = false
		if held_piece:
			held_piece.visible = false
		next_piece.visible = false
	$MidiPlayer.stop()
	$DropTimer.stop()
	$LockDelay.stop()
	$Stats/Clock.stop()

func game_over():
	$FlashText.print("GAME\nOVER")
	pause(false)
	$ReplayButton.visible = true

func _on_ReplayButton_pressed():
	pause()
	$ReplayButton.visible = false
	$Start.visible = true
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if playing:
				pause()
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			save_user_data()
			get_tree().quit()

func save_user_data():
	var save_game = File.new()
	save_game.open_encrypted_with_pass("user://data.save", File.WRITE, password)
	save_game.store_line(str($Stats.high_score))
	save_game.close()
