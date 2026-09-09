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

@export var scores : Dictionary[String, int] = {}
@export var playerNames : Dictionary[String, String] = {}


func _ready():
	AudioServer.set_bus_volume_db(audioBus, -30)

@rpc("authority", "call_remote", "reliable")
func _add_player_to_score_board(player):
	scores.get_or_add(player, 0)

@rpc("authority","call_remote", "reliable")
func _add_gamer_tag(player,tag):
	playerNames.get_or_add(player, tag )

@rpc("authority","call_remote", "reliable")
func _get_gamer_tag(player):
	print(playerNames)
	if playerNames.has(player.name):	
		return playerNames[player.name]
	else:
		return "steve"
		
func _physics_process(delta):
	totalTime += delta
	roundTime += delta
	
@rpc("authority", "call_remote", "reliable")
func _update_score(player, object_to_get_score):	
	scores[player.name] += 1
	print(scores)
	#score_changed.emit()

@rpc("authority", "call_remote", "reliable")
func _get_score():
	return scores
