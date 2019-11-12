extends Node

# Configuration file format (settings) used by Linux
const CONFIG_FILE = "user://config.cfg"

const CONFIG_WINDOW = "window"
const CONFIG_WINDOW_SIZE = "size"
const CONFIG_WINDOW_POS = "position"

### Ready Function
## Calls Load Screen Config - configures window size/position
## Makes Pause screen invisible
## Connects screen_size change signal to function to save new screen size. 
func _ready():
	$MainCtr/pause.visible = false
	#yeet
	$MainCtr/board.visible = false


	_load_screen_config()
	#warning-ignore:return_value_discarded
	
	#if the screen is resized, save the new value with function _save_screen_size()
	get_tree().connect("screen_resized", self, "_save_screen_size")

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if not $MainCtr/title.visible:
				_on_board_pause()
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_save_screen_pos()

### Screen Configuration
func _load_screen_config():
	## Creates a Config file object
	#INI is initialization format used by windows to set params. Is plain text.
	#Format, all information is indentified by a section and a key. 
	var config = ConfigFile.new()
	#loads a config file
	var err = config.load(CONFIG_FILE)
	#If the file wasn't loaded, or if it doesn't contain window size information
	if (err != OK) \
			or not config.has_section_key(CONFIG_WINDOW, CONFIG_WINDOW_SIZE) \
			or not config.has_section_key(CONFIG_WINDOW, CONFIG_WINDOW_POS):
		##has_section_key returns TRUE if section-key pair exist. 
		##set_value (section, key, value) = Assigns a value to the specified key of the specified section. 
		#If the section and/or the key do not exist, they are created. 
		##OS.window_position is relative to the top left corner like normal. window_size/positoin have default values. 
		config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_size)
		config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_position)
		config.save(CONFIG_FILE)
	else:
		#Get the window size and position and save it to OS properties.
		var window_size = config.get_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE)
		OS.window_size = window_size
		var window_pos = config.get_value(CONFIG_WINDOW, CONFIG_WINDOW_POS)
		OS.window_position = window_pos

## save the new sreen size in case it changes. 
func _save_screen_size():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	assert(err == OK)
	config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE, OS.window_size)
	config.save(CONFIG_FILE)

#Save screen position 
func _save_screen_pos():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	assert(err == OK)
	config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_position)
	config.save(CONFIG_FILE)

## Signal responce from start button on title page
func _on_title_start():
	$MainCtr/title.visible = false
	## yeet
	$MainCtr/board.visible = true
	$MainCtr/board.start_game()

##Signal responce from board
# Makes the title scene visible
func _on_board_game_over():
	$MainCtr/title.visible = true
	$MainCtr/board.visible = false

## Signal responce from board ... 
# Gets pause scene and makes it visible.
func _on_board_pause():
	get_tree().paused = true
	$MainCtr/pause.visible = true

#Signal responce
func _on_pause_end_game():
	$MainCtr/board.end_game()
	$MainCtr/title.visible = true
	$MainCtr/board.visible = false
