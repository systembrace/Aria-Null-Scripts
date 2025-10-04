extends PointLight2D
class_name CustomLight

@export var shadows=false

func _ready():
	if height==0:
		height=64
	if !shadows:
		range_item_cull_mask=1
		shadow_enabled=false
		return
		
	range_item_cull_mask=2
	energy/=2
	
	var toplight=PointLight2D.new()
	toplight.energy=energy
	toplight.range_item_cull_mask=3
	toplight.shadow_enabled=false
	toplight.texture=texture
	toplight.texture_scale=texture_scale
	toplight.height=height
	add_child(toplight)
	
	shadow_enabled=true
	shadow_item_cull_mask=2

func enable():
	enabled=true
	
func disable():
	enabled=false
