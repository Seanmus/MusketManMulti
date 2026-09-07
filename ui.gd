extends Control


@onready var topDownCamera = $miniMap/topDown/topDownCamera
@onready var topDownViewPort = $miniMap/topDown
@onready var levelTime = $levelTime
@onready var gameTime = $gameTime
@onready var miniMap = $miniMap

@onready var GoldTimeLabel = $GoldTime
@onready var SilverTimeLabel = $SilverTime
@onready var BronzeTimeLabel = $BronzeTime

@onready var GoldTrophy = $GoldTrophy
@onready var SilverTrophy = $SilverTrophy
@onready var BronzeTrophy = $BronzeTrophy

@onready var playerLabels = [$LeaderboardPanel/Player1, $LeaderboardPanel/Player2, 
$LeaderboardPanel/Player3, $LeaderboardPanel/Player4, $LeaderboardPanel/Player5, $LeaderboardPanel/Player6, 
$LeaderboardPanel/Player7, $LeaderboardPanel/Player8, $LeaderboardPanel/Player9, $LeaderboardPanel/Player10] 

var endLevel

var GoldTime : float
var SilverTime : float
var BronzeTime : float

var playerSpeed

# Called when the node enters the scene tree for the first time.
func _ready():	
	Manager.addTime.connect(_addTime)
	_hide()

func _SetRoundTimes(Gold, Silver, Bronze):
	GoldTime = Gold
	SilverTime = Silver
	BronzeTime = Bronze
	GoldTimeLabel.text =   "%02d.%02d" % [Gold, fmod(Gold,1) * 1000]
	SilverTimeLabel.text = "%02d.%02d" % [Silver, fmod(Silver,1) * 1000]
	BronzeTimeLabel.text = "%02d.%02d" % [Bronze, fmod(Bronze,1) * 1000]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Manager.paused:
		return
	$Speed.text = str(playerSpeed) + " MPH"
	if playerSpeed == 400:
		print("max speed reached achievement")
		var ACH = "ACH_MaxSpeed"
		Manager._SetAchievement(ACH)
	levelTime.text = "%02d.%02d" % [Manager.roundTime, fmod(Manager.roundTime,1) * 1000]
	gameTime.text = "%02d.%02d" % [Manager.totalTime, fmod(Manager.totalTime,1) * 1000]
	#_HighlightTime()
	if Input.is_action_just_pressed("escape"):
		Manager.totalTime = 1000
		get_tree().change_scene_to_file("res://Worlds/title.tscn")
		

func _HighlightTime():
	return
	GoldTrophy.frame = 0
	SilverTrophy.frame = 0
	BronzeTrophy.frame = 0
	if Manager.roundTime <= GoldTime:
		GoldTrophy.visible = true
		SilverTrophy.visible = false
		BronzeTrophy.visible = false
		
		if (GoldTime - Manager.roundTime) / Manager.roundTime > 0.2:
			GoldTrophy.frame = 0
		elif (GoldTime - Manager.roundTime) / Manager.roundTime > 0.1: 
			GoldTrophy.frame = 1
		else:
			GoldTrophy.frame = 2
	elif Manager.roundTime <= SilverTime:
		GoldTrophy.visible = true
		SilverTrophy.visible = true
		BronzeTrophy.visible = false
		
		GoldTrophy.frame = 3
		if (SilverTime - Manager.roundTime) / Manager.roundTime > 0.2:
			SilverTrophy.frame = 0
		elif (SilverTime - Manager.roundTime) / Manager.roundTime > 0.1: 
			SilverTrophy.frame = 1
		else:
			SilverTrophy.frame = 2		
	elif Manager.roundTime <= BronzeTime:
		GoldTrophy.visible = true
		SilverTrophy.visible = true
		BronzeTrophy.visible = true
		
		GoldTrophy.frame = 3
		SilverTrophy.frame = 3
		if (BronzeTime - Manager.roundTime) / Manager.roundTime > 0.2:
			BronzeTrophy.frame = 0
		elif (BronzeTime - Manager.roundTime) / Manager.roundTime > 0.1: 
			BronzeTrophy.frame = 1
		else:
			BronzeTrophy.frame = 2
	else:
		GoldTrophy.frame = 3
		SilverTrophy.frame = 3
		BronzeTrophy.frame = 3	
	if GoldTime == 0:
		_hide()

func _show():
	levelTime.visible = true 
	gameTime.visible = true
	miniMap.visible = true
	
	#GoldTimeLabel.visible = true
	#SilverTimeLabel.visible = true
	#BronzeTimeLabel.visible = true
	$Speed.visible = true
	if Manager.isCrossHairEnabled:
		$Cursor.visible = true
	
func _hide():
	$LeaderboardPanel.visible = false
	GoldTrophy.visible = false
	SilverTrophy.visible = false
	BronzeTrophy.visible = false
	
	GoldTimeLabel.visible = false
	SilverTimeLabel.visible = false
	BronzeTimeLabel.visible = false
	
	miniMap.visible = false
	levelTime.visible = false
	gameTime.visible = false
	$Speed.visible = false
	$Cursor.visible = false

func _addTime():
	$levelTime/levelTimeAddTimeAnim.play("addTime")

func _ShowHighscores(result):
	if(Manager.gameMode == Manager.GAME_MODES.LEVEL):
		$LeaderboardPanel/CurrentScore.text = "Your Time: " + "%02d.%02d" % [Manager.finalRoundTime, fmod(Manager.finalRoundTime,1) * 1000]
	else:
		$LeaderboardPanel/CurrentScore.text = "Your Time: " + "%02d.%02d" % [Manager.finalSetTime, fmod(Manager.finalSetTime,1) * 1000]
	$LeaderboardPanel/NextLevelBtn.grab_focus()	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	$LeaderboardPanel.visible = true
	for label in playerLabels:
		label.visible = false
	var i = 0
	for r in result:
		var name = Steam.getFriendPersonaName(r["steam_id"])
		var score : float = r["score"]
		print(name + " Score : " + str(score))
		playerLabels[i].text = name + " Time: " + str(score/1000)
		playerLabels[i].visible = true
		i+= 1

		
	
func _UpdateMiniMapCamera(posX, posZ):
	$miniMap/topDown/topDownCamera.position.x = posX
	$miniMap/topDown/topDownCamera.position.z = posZ

func _on_next_level_btn_button_down():
	$LeaderboardPanel.visible = false
	if Manager.gameMode == Manager.GAME_MODES.GAUNTLET:
		get_tree().change_scene_to_file("res://Worlds/title.tscn")	
	else:
		endLevel._nextScene()


func _on_retry_level_btn_button_down():
	$LeaderboardPanel.visible = false
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)	
