extends CollisionShape2D
class_name TileSwapper

var main
var nav_map:TileMapLayer

func _ready():
	main=get_tree().get_root().get_node("Main")
	call_deferred("swap")
	
func swap(nav=false,pos=global_position):
	if !main.is_node_ready:
		await main.ready
	nav_map=main.nav_map
	pos=round(pos)
	var atlas_coords=Vector2i(0,1)
	if nav:
		atlas_coords=Vector2i(2,0)
	var offs=round(abs(shape.size.rotated(global_rotation)/2))
	var top_left=Vector2i(round((pos-offs)/16))
	var bottom_right=Vector2i(round((pos+offs)/16))
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):
			nav_map.set_cell(Vector2i(x,y),0,atlas_coords,0)
