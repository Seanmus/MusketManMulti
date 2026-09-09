extends Panel

@export var player: Node3D
@onready var main = player.main

func _process(delta: float) -> void:
	_update_score()

func _update_score():
	if(!Manager) || !is_multiplayer_authority():
		print("Manager is null")
		return
	print(main)
	var scores = Manager._get_score()
	if(!scores):
		print("No score returned from Manager in UI on player")
		return
	var scoreText = ""
	for key in scores:
		scoreText += "Player " + str(key) + " :Score " + str(scores[key]) + "\n"
	$YourScore.text = scoreText
