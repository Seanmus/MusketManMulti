extends StaticBody3D

var speed = 25

func _physics_process(delta: float) -> void:
	var forward = global_transform.basis.z
	global_position += (forward * speed * delta) / scale.x
