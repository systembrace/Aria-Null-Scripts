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
	if song and !track.replace_current:
		song.stopped.connect(track.play)
		eject(5)
	elif song and track.replace_current:
		song.stop()
		song.queue_free()
		song=null
		track.play()
	else:
		track.play()
	song=track

func eject(speed=5.0):
	if !is_instance_valid(song):
		return
	print("ejecting "+song.name)
	song.fade_out(speed)
	song=null
