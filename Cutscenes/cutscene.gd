extends Node2D
class_name Cutscene

@export var sequence_name="intro"
@export var go_to_after="directory/startroom"
var sequence:ConfigFile
var index=0
var dialogue_counter=0
var slide_counter=0
var done=false
var fade=-1
var skip_time=0.0
@onready var dialogue_box=$Dialogue
@onready var slides=$Slides
@onready var timer=$Timer

func _ready():
	Music.eject(1)
	sequence=ConfigFile.new()
	sequence.load("res://Dialogue/Cutscenes/"+sequence_name+".ini")
	Global.dialogue_ended.connect(next)
	timer.timeout.connect(next)
	timer.wait_time=3
	timer.start()
	slides.hide()
	dialogue_box.hide()

func next():
	index+=1
	done=true

func next_dialogue():
	dialogue_counter+=1
	dialogue_box.enter(sequence,"Dialogue"+str(dialogue_counter),true)

func next_slide():
	slide_counter+=1
	slides.animation=str(slide_counter)
	if sequence.has_section_key("Sequence",str(index)+"fade_in"):
		slides.modulate.a=0
		fade=1.0
	slides.show()
	slides.play()

func end():
	var scene=load("res://Maps/"+go_to_after+".tscn")
	get_tree().call_deferred("change_scene_to_packed",scene)

func _process(delta):
	if Input.is_action_pressed("pause"):
		skip_time+=delta
	elif skip_time>0:
		skip_time=0
	if skip_time>5:
		end()
	
	if fade!=-1 and slides.modulate.a!=fade:
		slides.modulate.a=move_toward(slides.modulate.a,fade,delta)
	elif fade!=-1:
		fade=-1
	
	if done:
		done=false
		var do=sequence.get_value("Sequence",str(index))
		if do=="Both":
			next_dialogue()
			next_slide()
		elif do=="Dialogue":
			next_dialogue()
		elif do=="Slide":
			next_slide()
			next()
		elif do=="Hide":
			slides.hide()
			next()
		elif do=="Fade_out":
			fade=0
			next()
		elif do.begins_with("Wait"):
			timer.wait_time=float(do.substr(4))
			timer.start()
		elif do=="End":
			end()
