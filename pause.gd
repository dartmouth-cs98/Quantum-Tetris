extends Control

signal end_game

func _on_continue_pressed():
	get_tree().paused = false
	visible = false

func _on_quit_pressed():
	get_tree().paused = false
	visible = false
	emit_signal("end_game")