extends Panel

@export var player: Node3D
@onready var main = player.main

func _request_update_score():
	if not multiplayer.is_server(): return
	_get_score.rpc()

@rpc("any_peer", "call_local", "reliable")
func _get_score():
	if not multiplayer.is_server(): return
	var scores = Manager.scores
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = 1
		
	print("sender_id " + str(sender_id))
	print("Scores :" + str(scores))
	_receive_score.rpc_id(sender_id, scores)


#@rpc("authority")
@rpc("authority", "call_local")
func _receive_score(scores):
	print(scores)
	if(!scores):
		print("No score returned from Manager in UI on player")
		return
	var scoreText = ""
	for key in scores:
		scoreText += "Player " + str(key) + " :Score " + str(scores[key]) + "\n"
	$YourScore.text = scoreText
