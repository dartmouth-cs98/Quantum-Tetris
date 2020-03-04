extends Control

signal start(level)
signal tutorial(level, tutorial)

func _on_PlayButton_pressed():
	emit_signal("start", $SpinBox.value)
	
func _on_HowToButton_pressed():

	emit_signal("tutorial", 1, true)