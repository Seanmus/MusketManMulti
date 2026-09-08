extends Panel

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
		
	if Input.is_action_just_pressed("pause"):
		visible = !visible	
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _on_quit_button_button_down() -> void:
	get_tree().quit()
