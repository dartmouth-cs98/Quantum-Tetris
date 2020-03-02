extends Control

var num = 0

func _ready():
	num = 0
	for child in $MarginContainer/VBoxContainer.get_children():
		if child.get_class() != "Label":
			child.visible = false


func add_powerup() -> bool:
	if num < 4 :
		num += 1
		$MarginContainer/VBoxContainer.get_child(num).visible = true
		return true
	else:
		return false

func use_powerup() -> bool:
	if num > 0:
		$MarginContainer/VBoxContainer.get_child(num).visible = false
		num -= 1
		return true
	else:
		return false
	
	
func clear(): 

	while use_powerup():
		pass

