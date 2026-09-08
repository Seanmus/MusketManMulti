extends Panel

func _ready() -> void:
	Manager.score_changed.connect(_update_score)
	
func _update_score():
	var scores = Manager._get_score()
	var scoreText = ""
	for key in scores:
		scoreText += "Player " + str(key) + " :Score " + str(scores[key]) + "\n"
	$YourScore.text = scoreText
