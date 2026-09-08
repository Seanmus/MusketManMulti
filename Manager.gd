extends Node
@onready var audioBus := AudioServer.get_bus_index("Master")
var sceneName = "tutorial"
var scenePath = "tutorial"

enum GAME_MODES{LEVEL, SET, GAUNTLET}

var gameMode = GAME_MODES.LEVEL

signal resetPlatforms
signal addTime

var bestTime = 10000
var totalTime = 0
#Set on the end level node
var roundTime = 0.0

var showPlatformTime = 4


var verticalMouseLocked = true
var mouseSensitivity = 0.0015


var boardHandle : int
var leaderboard_handle

var paused = false

var finalRoundTime = 0
var finalSetTime = 0

var isFinalOfSet
var isFinalLevel

var isCrossHairEnabled = true


var scores : Dictionary[String, int] = {}

signal score_changed


func _ready():
	AudioServer.set_bus_volume_db(audioBus, -30)



@rpc("any_peer", "call_local", "reliable")
func _update_score(id, score):
	if not multiplayer.is_server():
		return
		
	scores[id] += score
	print(scores)
	score_changed.emit()

@rpc("any_peer", "call_local", "reliable")
func _get_score():
	if not multiplayer.is_server():
		return
	return scores


func _physics_process(delta):
	totalTime += delta
	roundTime += delta
