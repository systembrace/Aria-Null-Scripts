extends PointLight2D
class_name Spotlight

@export var sprite_alpha=.25
@export var floodlight=false
@export var flicker=false
var main
var player

func _ready():
	shadow_enabled=false
	main=get_tree().get_root().get_node("Main")
	texture=load("res://Assets/Art/environment/spotlight.tres")
	texture_scale=1
	energy=1
	height=32
	$Hum.play()
	if floodlight:
		$Sprite2D.texture=load("res://Assets/Art/environment/floodlight.png")
		$PointLight2D.texture=load("res://Assets/Art/environment/floodlight.png")
	$Sprite2D.modulate.a=sprite_alpha

func switch_light(_body=null,mask=5):
	$PointLight2D.range_item_cull_mask=mask

func _process(_delta):
	if flicker and visible and randf()*60<=.8:
		visible=false
		$Flicker.play()
		$Hum.stop()
	elif flicker and not visible and randf()*60<2:
		visible=true
		$Flicker.play()
		if !$Hum.is_playing():
			$Hum.play()
	if !is_instance_valid(player):
		player=main.find_child("Player",true,false)
		return
	$PointLight2D.energy=clamp(to_local(player.global_position+Vector2(0,36)).length(),0,64)/64.0*energy
