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






func _ready():
	AudioServer.set_bus_volume_db(audioBus, -30)





func _physics_process(delta):
	totalTime += delta
	roundTime += delta
