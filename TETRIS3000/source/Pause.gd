extends Control

func _input(event):
	if event.is_action_pressed(""):
		var new_tutorial_state = not get_tree().paused
		get_tree().paused = new_tutorial_state
		visible = new_tutorial_state