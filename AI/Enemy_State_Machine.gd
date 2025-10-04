extends StateMachine
class_name EnemyStateMachine

func _ready():
	if not body.spawn:
		body.spawn=body.global_position
	super._ready()

func take_damage(area=null, _parry=false):
	if area.targetparent is Player:
		Global.hitstop(.02)

func death_throes():
	$ScrapSpawner.particles["scrap"]=Vector2(body.scrap,body.scrap)
	$ScrapSpawner.spawn(false,body.global_position)
	super.death_throes()

func die():
	if !body.on_floor:
		return
	dead=true
	var main=get_tree().get_root().get_node("Main")
	if main:
		var corpse=load("res://Scenes/General/corpse.tscn").instantiate()
		corpse.global_position=body.global_position
		corpse.type=body.type
		main.add_child(corpse)
	body.queue_free()
