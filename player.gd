extends CharacterBody3D


const SPEED = 20
var currentSpeed = SPEED
const MAXSPEED = 100
const JUMP_VELOCITY = 13
var mouse_sensitivty = Manager.mouseSensitivity
var controller_sensitivity = 0.05
var spawnPos
var landing : bool 
var coyoteTime : bool
var jumped : bool
var startedMoving : bool
var gamer_tag = "CoolGuy"
var main

var multiplayer_id = 0
@export var dead : bool = false
@export var multiplayer_velocity : Vector3
@export var multiplayer_grounded: bool = false
@onready var coyoteTimer = $coyoteTimer
@onready var anim = $AnimationPlayer
@onready var landed = $landed

@onready var speedEffect = $Pivot/SpeedEffect
@onready var cam = $Pivot/Camera3d


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@rpc("any_peer", "call_local", "reliable")
func _set_gamer_tag(tag):
	$GamerTag.text = tag

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready():
	main = get_tree().get_root().find_child("Main")
	Manager.roundTime = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spawnPos = global_transform
	landing = false
	if is_multiplayer_authority():
		dead = false
		cam.current = is_multiplayer_authority()

func _unhandled_input(event):
	set_multiplayer_authority(name.to_int())
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivty)
		if !Manager.verticalMouseLocked:
			$Pivot.rotate_x(-event.relative.y * mouse_sensitivty)
			#$Pivot.rotate_z(event.relative.x * mouse_sensitivty)
		
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if dead:
		return
	cam.current = is_multiplayer_authority()
	$GamerTag.text = Manager._get_gamer_tag(self)
	#var cameraInput = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	#if cameraInput:
		#pass
		#rotate_y(-cameraInput.x * controller_sensitivity)
		#rotate_x(cameraInput.y * controller_sensitivity)
	
	if not is_on_floor():
		if(landing):
			coyoteTime = true
			coyoteTimer.start()
		landing = false
		velocity.y -= gravity * delta * 2
		if velocity.y <= 0:
			velocity.y -= gravity * delta * 3
	else:
		if !landing:
			landing = true
			jumped = false
			anim.play("landing")
			landed.play()
	# Handles Jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || coyoteTime) and not jumped:
		velocity.y = JUMP_VELOCITY
		jumped = true	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		currentSpeed += 1.5 * delta
		currentSpeed = clamp(currentSpeed, SPEED, MAXSPEED)
		if input_dir.y < 0:
			speedEffect.visible = true
			speedEffect.initial_velocity_max = 88 * (currentSpeed / 4.5)
			speedEffect.initial_velocity_min = 88 * (currentSpeed / 4.5)
		else:
			speedEffect.visible = false
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
		if not startedMoving:
			anim.play("move")
			startedMoving = true
	else:
		currentSpeed = SPEED
		speedEffect.visible = false
		velocity.x = move_toward(velocity.x, 0, SPEED/2)
		velocity.z = move_toward(velocity.z, 0, SPEED/2)
		startedMoving = false
	multiplayer_velocity = velocity
	multiplayer_grounded = is_on_floor()
	move_and_slide()
func _respawn():
	Manager.roundTime = 0
	call_deferred("_resetScene")


func _resetScene():
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)	


func Bounce():
	velocity.y = JUMP_VELOCITY * 2

func _on_coyote_timer_timeout():
	coyoteTime = false

func _Respawn():
	if is_multiplayer_authority():
		dead = false
		velocity.y = 0
		$DeadPanel.visible = false
		global_transform = spawnPos

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if is_multiplayer_authority():
		if body.is_in_group("danger"):
			print("Name " + str(name))
			#print("MultiplayerId " + str(multiplayer_id))
			#main._update_score.rpc(name, 1)
			Manager._update_score.rpc(self.name, body)
			dead = true
			print("that hurt!")
			$DeadPanel.visible = true
			$RespawnTimer.start()
