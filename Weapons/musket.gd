extends Node3D

@onready var muzzle = $SpawnPoint
@export var bullet : PackedScene
@onready var spawnContainter = get_node("/root/Main/Bullets")
@onready var bulletSpawner = get_node("/root/Main/BulletSpawner")
var canShoot = true


func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("click"):
		if canShoot:
			print("shooting")
			canShoot = false
			$CanShoot.start()
			shoot.rpc(muzzle.global_position, muzzle.global_rotation)


@rpc("any_peer", "call_local", "reliable")
func shoot(muzzle_position, muzzle_rotation):
	if not multiplayer.is_server():
		return
		
	var s = bullet.instantiate()
	spawnContainter.add_child(s, true)
	s.global_position = muzzle_position
	s.rotation = muzzle_rotation


func _on_can_shoot_timeout() -> void:
	canShoot = true
