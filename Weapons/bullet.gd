extends StaticBody3D

var speed = 125

func _physics_process(delta: float) -> void:
	var forward = global_transform.basis.z
	global_position += (forward * speed * delta) / scale.x


func _on_timer_timeout() -> void:
	if is_multiplayer_authority():
		queue_free()


func _on_bounce_collider_body_entered(body: Node3D) -> void:
	if !body.is_in_group("danger"):
		speed = speed * -1
