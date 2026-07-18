@tool
extends AnimatedSprite2D
class_name RailTile

@export var speed=2.5
@export var stop=false
@export var occ_by: PushBlock
@export_category("Moving ____ redirects to:")
@export var up: RailTile
@export var left: RailTile
@export var right: RailTile
@export var down: RailTile
var dir_map={
	Vector2.DOWN:null,
	Vector2.RIGHT:null,
	Vector2.LEFT:null,
	Vector2.UP:null
}
var turn_map={
	Vector2.DOWN:0,
	Vector2.RIGHT:0,
	Vector2.LEFT:0,
	Vector2.UP:0
}
var next_move: RailTile
var rotate=0

func _ready():
	if stop:
		animation="stop"
	else:
		animation="pass"
	if up:
		dir_map[Vector2.UP]=up
		var dir=get_dir(up)
		if dir==Vector2.DOWN:
			$Up.show()
		elif dir==Vector2.LEFT:
			turn_map[Vector2.UP]=-1
		elif dir==Vector2.RIGHT:
			turn_map[Vector2.UP]=1
	if right:
		dir_map[Vector2.RIGHT]=right
		var dir=get_dir(right)
		if dir==Vector2.LEFT:
			$Right.show()
		elif dir==Vector2.UP:
			turn_map[Vector2.RIGHT]=-1
		elif dir==Vector2.DOWN:
			turn_map[Vector2.RIGHT]=1
	if left:
		dir_map[Vector2.LEFT]=left
		var dir=get_dir(left)
		if dir==Vector2.RIGHT:
			$Left.show()
		elif dir==Vector2.DOWN:
			turn_map[Vector2.LEFT]=-1
		elif dir==Vector2.UP:
			turn_map[Vector2.LEFT]=1
	if down:
		dir_map[Vector2.DOWN]=down
		var dir=get_dir(down)
		if dir==Vector2.UP:
			$Down.show()
		elif dir==Vector2.RIGHT:
			turn_map[Vector2.DOWN]=-1
		elif dir==Vector2.LEFT:
			turn_map[Vector2.DOWN]=1

func get_dir(node: Node2D):
	return to_local(node.global_position).normalized().round()

func try_move_obj(dir):
	var snap_dir=Global.snap_vector_angle(dir).normalized().round()
	if snap_dir in dir_map:
		next_move=dir_map[snap_dir]
	if next_move:
		occ_by.tileswapper.swap(true)
		give_to_next()
		return true
	else:
		return false

func give_to_next(leftover=0):
	occ_by.global_position=global_position
	occ_by.dir=to_local(next_move.global_position).normalized().round()
	next_move.receive(occ_by)
	occ_by.global_position+=occ_by.dir*leftover
	occ_by=null
	next_move=null

func receive(obj):
	occ_by=obj
	occ_by.occupying=self
	rotate=turn_map[occ_by.dir]
	if rotate!=0 and !occ_by.turning:
		occ_by.turning=self
	if !stop:
		next_move=dir_map[occ_by.dir]

func stop_occ():
	occ_by.global_position=global_position
	occ_by.stop()
	occ_by.dir=Vector2.ZERO
	occ_by.mod=1
	occ_by.tileswapper.swap()

func _physics_process(delta):
	if Engine.is_editor_hint() or !occ_by or occ_by.dir.length()==0:
		return
	if occ_by.velocity.length()!=speed*occ_by.mod:
		occ_by.velocity=occ_by.velocity.move_toward(occ_by.dir*speed*occ_by.mod,occ_by.accel*60*delta)
	if occ_by.global_position.round()!=global_position:
		occ_by.global_position+=occ_by.velocity.length()*occ_by.dir
		if get_dir(occ_by)!=(-occ_by.dir).round():
			var leftover=(global_position-occ_by.global_position).length()
			if next_move:
				give_to_next(leftover)
			else:
				stop_occ()
	elif next_move:
		give_to_next()
	else:
		stop_occ()
