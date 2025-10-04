extends Node
class_name MusicPlayer

var db=0
@export var main_track:AudioStreamPlayer
@export var autoplay=true
@export var loop=true
@export var init_db=0

func _ready():
	db=init_db+Global.load_config("audio","music")
	main_track.volume_db=db
	process_mode=Node.PROCESS_MODE_ALWAYS
	if autoplay:
		play()
	if loop:
		main_track.finished.connect(play)

func play():
	db=init_db+Global.load_config("audio","music")
	main_track.volume_db=db
	main_track.play()

func _process(_delta):
	if db!=init_db+Global.load_config("audio","music"):
		db=init_db+Global.load_config("audio","music")
		main_track.volume_db=db
	
	if abs(main_track.volume_db-db)<.005 and get_tree().paused:
		main_track.volume_db=db-7
	elif abs(main_track.volume_db-db+7)<.005 and !get_tree().paused:
		main_track.volume_db=db
