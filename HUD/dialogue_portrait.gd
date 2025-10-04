@tool
extends TextureRect
class_name DialoguePortrait

@export var test_dialogue_file: String
@export var test_dialogue_section: String
@export var test_face=false
@export var eyes_index=1
@export var eyebrows_index=1
@export var mouth_index=1
@export var shoulders_index=1
var eyes
var eyebrows
var shoulders
var mouth
var section_index=0

func _ready():
	draw_portrait()
	if test_dialogue_file and Engine.is_editor_hint():
		var dialogue_box=get_parent().get_parent().get_parent().get_parent()
		await dialogue_box.ready
		var data=ConfigFile.new()
		data.load("res://dialogue/"+test_dialogue_file+".ini")
		if test_dialogue_section:
			get_parent().get_parent().get_parent().get_parent().enter(data,test_dialogue_section,true)
			return
		dialogue_box.exited.connect(test_next_section.bind(data))
		test_next_section(data)

func test_next_section(data):
	if section_index>=len(data.get_sections()):
		return
	get_parent().get_parent().get_parent().get_parent().enter(data,data.get_sections()[section_index],true)
	section_index+=1

func _draw():
	if shoulders:
		draw_texture(shoulders,Vector2.ZERO)
	if mouth:
		draw_texture(mouth,Vector2.ZERO)
	if eyebrows:
		draw_texture(eyebrows,Vector2.ZERO)
	if eyes:
		draw_texture(eyes,Vector2.ZERO)

func draw_portrait(current_data=null,current_section=null,index=1):
	if !test_face or !Engine.is_editor_hint():
		eyes_index=1
		eyebrows_index=1
		mouth_index=1
		shoulders_index=1
	var speaker="cherry"
	if current_data:
		if current_data.has_section_key(current_section,str(index)+"speaker"):
			speaker=current_data.get_value(current_section,str(index)+"speaker")
		if current_data.has_section_key(current_section,str(index)+"eyebrows"):
			eyebrows_index=current_data.get_value(current_section,str(index)+"eyebrows")
		if current_data.has_section_key(current_section,str(index)+"eyes"):
			eyes_index=current_data.get_value(current_section,str(index)+"eyes")
		if current_data.has_section_key(current_section,str(index)+"mouth"):
			mouth_index=current_data.get_value(current_section,str(index)+"mouth")
		if current_data.has_section_key(current_section,str(index)+"shoulders"):
			shoulders_index=current_data.get_value(current_section,str(index)+"shoulders")
	shoulders=null
	mouth=null
	eyebrows=null
	eyes=null
	texture=load("res://Assets/Art/portraits/"+speaker+"/head.png")
	if DirAccess.dir_exists_absolute("res://Assets/Art/portraits/"+speaker+"/shoulders"):
		shoulders=load("res://Assets/Art/portraits/"+speaker+"/shoulders/shoulders"+str(shoulders_index)+".png")
	if DirAccess.dir_exists_absolute("res://Assets/Art/portraits/"+speaker+"/mouths"):
		mouth=load("res://Assets/Art/portraits/"+speaker+"/mouths/mouth"+str(mouth_index)+".png")
	if DirAccess.dir_exists_absolute("res://Assets/Art/portraits/"+speaker+"/eyebrows"):
		eyebrows=load("res://Assets/Art/portraits/"+speaker+"/eyebrows/eyebrows"+str(eyebrows_index)+".png")
	if DirAccess.dir_exists_absolute("res://Assets/Art/portraits/"+speaker+"/eyes"):
		eyes=load("res://Assets/Art/portraits/"+speaker+"/eyes/eyes"+str(eyes_index)+".png")
	queue_redraw()
