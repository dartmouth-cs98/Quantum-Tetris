extends Control

var texts = PoolStringArray()

func print(text):
	texts.append(text)
	if texts.size() > 4:
		texts.remove(0)
	$Label.text = texts.join("\n")
	$AnimationPlayer.play("Flash")

func _on_AnimationPlayer_animation_finished(anim_name):
	texts.resize(0)

func _on_Stats_flash_text(text):
	self.print(text)
