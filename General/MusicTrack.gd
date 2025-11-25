extends Node
class_name MusicTrack

@export var autoplay=true
@export var loop=true
@export var init_db=0.0
@export var autoplay_if_flag:String
@export var flag_is_value=1.0
signal stopped
var loaded=false
var db=0.0
var pause_offset=0.0
var fading=false
var fade_speed=1
var calm_db=0.0
var combat_db=-64.0
var time_scale=1.0
var pitch_scale=1.0
var base: AudioStreamPlayer
var calm: AudioStreamPlayer
var combat: AudioStreamPlayer

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	base=find_child("Base")
	calm=find_child("Calm")
	combat=find_child("Combat")
	if loop and base:
		base.finished.connect(play)
	if autoplay:
		call_deferred("try_autoplay")

func try_autoplay():
	if !autoplay_if_flag or Global.get_flag(autoplay_if_flag)==flag_is_value:
		call_deferred("load_track")

func update_volume():
	if !base:
		return
	db=init_db+Global.load_config("audio","music")
	base.volume_db=db+pause_offset
	if calm:
		calm.volume_db=db+calm_db+pause_offset
	if combat:
		combat.volume_db=db+combat_db+pause_offset

func load_track():
	if loaded:
		return
	loaded=true
	if base:
		Music.insert(self)
	else:
		Music.eject()

func play():
	print("Playing "+name)
	db=init_db+Global.load_config("audio","music")
	update_volume()
	base.play()
	if calm:
		calm.play()
	if combat:
		combat.play()

func fade_out(speed):
	fading=true
	fade_speed=speed

func stop():
	stopped.emit()
	base.stop()
	if calm:
		calm.stop()
	if combat:
		combat.stop()

func _process(delta):
	if !base:
		return
	
	if fading:
		init_db=move_toward(init_db,-64,60*delta/fade_speed)
	if init_db<=-16:
		stop()
		queue_free()
	
	if time_scale!=Engine.time_scale:
		var diff=(Engine.time_scale-time_scale)/2
		pitch_scale+=diff
		time_scale=Engine.time_scale
		for child in get_children():
			child.pitch_scale=pitch_scale
	#elif time_scale==1.0 and base.pitch_scale!=1.0:
	#	base.pitch_scale=1.0
	#	if calm:
	#		calm.pitch_scale=1.0
	#	if combat:
	#		combat.pitch_scale=1.0
		
	if get_tree().paused and pause_offset==0.0 and not get_parent() is OptionsMenu:
		pause_offset=-7.0
		update_volume()
	elif !get_tree().paused and pause_offset!=0.0:
		pause_offset=0.0
		update_volume()

	if Global.in_combat and (combat_db<0 or calm_db>-64):
		combat_db=move_toward(combat_db,0,3*60*delta)
		calm_db=move_toward(calm_db,-64,3*60*delta)
		update_volume()
	elif !Global.in_combat and (calm_db<0 or combat_db>-64):
		calm_db=move_toward(calm_db,0,5*delta)
		combat_db=move_toward(combat_db,-64,5*delta)
		update_volume()
	elif db!=init_db+Global.load_config("audio","music"):
		update_volume()
