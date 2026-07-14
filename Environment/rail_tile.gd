extends Area2D
class_name RailTile

@export_category("Coming from:")
@export var above: RailTile
@export var left: RailTile
@export var right: RailTile
@export var below: RailTile
var dir_map={
	Vector2.DOWN:Vector2.ZERO,
	Vector2.RIGHT:Vector2.ZERO,
	Vector2.LEFT:Vector2.ZERO,
	Vector2.UP:Vector2.ZERO,
}
var occupied_by: PushBlock

func _ready():
	if above:
		dir_map[Vector2.DOWN]=to_local(above.global_position).normalized()
	if right:
		dir_map[Vector2.LEFT]=to_local(right.global_position).normalized()
	if left:
		dir_map[Vector2.RIGHT]=to_local(left.global_position).normalized()
	if below:
		dir_map[Vector2.UP]=to_local(below.global_position).normalized()
