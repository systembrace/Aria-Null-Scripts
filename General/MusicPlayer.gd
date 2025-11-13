extends Node
class_name MusicPlayer

var db=0.0
var song: MusicTrack

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS

func insert(track):
	if song and track.name==song.name:
		return
	print("Inserting "+track.name)
	track.call_deferred("reparent",self) 
	if song:
		song.stopped.connect(track.play)
		eject(4)
	else:
		track.play()
	song=track

func eject(speed=1):
	if !is_instance_valid(song):
		return
	print("ejecting "+song.name)
	song.fade_out(speed)
	song=null
