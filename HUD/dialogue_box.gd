@tool
extends Control
class_name DialogueBox

signal exited
var index=1
var text=""
var current_data:ConfigFile
var current_section=""
var control:PlayerControl
var speed=1
var eyebrows
var eyes
var mouth
var shoulders
var do_timer=false
var step=0
var dialogue_queue=[]
var currently_interruptable=true
var death_change=1
@onready var portrait=$PanelContainer/MarginContainer/HBoxContainer/Portrait
@onready var label=$PanelContainer/MarginContainer/HBoxContainer/Dialogue
@onready var timer=$Timer

func enter(data,section,t=false,node=null,interrupt=false,interruptable=true,change_on_death=-1):
	if current_section!="":
		if (!node and !interrupt) or !currently_interruptable:
			if !currently_interruptable and interrupt:
				dialogue_queue.clear()
			dialogue_queue.append([data,section,t,node,interruptable])
			return
		exit()
	if node:
		control=node
		control.call_deferred("pause")
	death_change=change_on_death
	currently_interruptable=interruptable
	do_timer=t
	if do_timer and !timer.timeout.is_connected(next):
		timer.timeout.connect(next)
	display(data,section)
	show()

func exit(clear_queue=false):
	hide()
	if death_change>=0:
		var heard_name=current_data.get_value("Info","room")+"_"+current_section
		if heard_name[-1].is_valid_int():
			heard_name=heard_name.substr(0,len(heard_name)-1)
		var play_number=Global.get_permanent_data("heard_dialogue",heard_name)
		print(heard_name)
		if play_number and play_number==death_change:
			Global.set_permanent_data("heard_dialogue",heard_name,play_number+1)
	if control:
		control.set_deferred("paused",false)
	if do_timer:
		do_timer=false
		timer.timeout.disconnect(next)
		timer.stop()
	control=null
	text=""
	current_section=""
	label.text=""
	exited.emit()
	if !Engine.is_editor_hint():
		Global.dialogue_ended.emit()
	if clear_queue:
		dialogue_queue.clear()
	if len(dialogue_queue)>0:
		var next_dialogue=dialogue_queue[0]
		dialogue_queue.remove_at(0)
		enter(next_dialogue[0],next_dialogue[1],next_dialogue[2],next_dialogue[3],next_dialogue[4])

func display(data:ConfigFile,section):
	label.text=""
	speed=1
	if current_data!=data:
		current_data=data
	if current_section!=section:
		index=1
		current_section=section
	if do_timer and current_data:
		timer.wait_time=max((current_data.get_value(current_section,str(index)).count(" ")+1)/3.0,1.5)
		timer.start()
	if data.has_section_key(section,str(index)):
		text=data.get_value(section,str(index))+"     "
	portrait.draw_portrait(current_data,current_section,index)

func next():
	$PanelContainer/MarginContainer/HBoxContainer/Next.hide()
	index+=1
	if !current_data.has_section_key(current_section,str(index)):
		exit()
		return
	display(current_data,current_section)

func reveal_text():
	if len(text)>0:
		if len(text)>5:
			label.text+=text[0]
		text=text.substr(1)

func _process(delta):
	if not $PanelContainer/MarginContainer/HBoxContainer/Dialogue.is_node_ready():
		await ready
	if !visible or !current_data:
		return
	step+=delta*50*speed
	var speaker="player"
	if current_data.has_section("Info"):
		speaker=current_data.get_value("Info","speaker")
	if current_data.has_section_key(current_section,str(index)+"speaker"):
		speaker=current_data.get_value(current_section,str(index)+"speaker").to_lower()
	if step>1:
		while step>0:
			if step>1:
				reveal_text()
			step-=1
		if len(text)>0 and text[0]!=" " and !Engine.is_editor_hint():
			var db=0
			if current_data.has_section_key(current_section,str(index)+"volume"):
				db=current_data.get_value(current_section,str(index)+"volume")
			find_child("Talk_"+speaker).play(0,db)
		step=0
	if do_timer:
		$PanelContainer/MarginContainer/HBoxContainer/Next.hide()
		return
	if len(text)<=0:
		$PanelContainer/MarginContainer/HBoxContainer/Next.show()
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack"):
			next()
		return
	if speaker!="eigon" and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("attack")):
		speed=4
		if !timer.is_stopped():
			timer.wait_time=timer.time_left/2.0
			timer.start()
	
