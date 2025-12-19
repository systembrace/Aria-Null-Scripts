class_name DirectoryLight
extends ColorRect

@export var tvs: Array
var texture: GradientTexture2D
var startx=8
var midx=5
var endx=4
var layery=[3,7,3]

func _ready():
	color="00000000"
	var x=global_position.x
	var y=global_position.y
	var length=size.x/16
	texture=GradientTexture2D.new()
	texture.fill=GradientTexture2D.FILL_RADIAL
	texture.gradient=Gradient.new()
	texture.gradient.reverse()
	texture.fill_from=Vector2(.5,.5)
	texture.fill_to=Vector2(.5,0)
	texture.width=64
	texture.height=64
	for dy in range(0,3):
		y+=8*dy
		var numlights=0
		for dx in range(0,length):
			if numlights>=5:
				continue
			x=global_position.x+16*dx
			var tempx=midx
			var tempy=layery[dy]
			if dx==0 and length!=2:
				tempx=startx
			elif dx==length-1 and length!=2:
				tempx=endx
			if Vector2(dx,dy) in tvs:
				if randi_range(0,2)==0:
					create_tv(x+tempx,y+tempy)
					numlights+=1
				continue
			for i in range(0,randi_range(-1,2)):
				create_light(x+tempx+randi_range(0,5),y+tempy+randi_range(0,3))
				numlights+=1
	$Hum.play(randf_range(0,$Hum.get_length()))
	$Hum.position=size/2

func create_light(x,y):
	var light=PointLight2D.new()
	add_child(light)
	light.global_position=Vector2(x,y)
	light.texture=texture
	light.height=64
	light.energy=6
	light.texture_scale=4/64.0
	light.range_item_cull_mask=16
	if randi_range(0,2)==0:
		light.color="14de76"
	else:
		light.color="e51250"
	var timer=Timer.new()
	if randi_range(0,4)==0:
		timer.wait_time=randf_range(0,.5)
	else:
		timer.wait_time=randf_range(1,5)
	add_child(timer)
	timer.timeout.connect(switch_light.bind(light))
	timer.start()

func create_tv(x,y):
	var tvtexture=load("res://Assets/Art/environment/tvlight.png")
	var light=PointLight2D.new()
	add_child(light)
	light.global_position=Vector2(x+3,y+1)
	light.texture=tvtexture
	light.height=64
	light.energy=20
	light.range_item_cull_mask=16

func switch_light(light):
	light.enabled=!light.enabled
