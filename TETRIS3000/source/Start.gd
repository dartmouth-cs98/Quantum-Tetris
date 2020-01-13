extends Control

signal start(level)

func _on_PlayButton_pressed():
	emit_signal("start", $SpinBox.value)