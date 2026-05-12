extends StateMachine
class_name EnemyStateMachine

@export var explode_on_death=false

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
	dead=true
	if !body.on_floor:
		return
	var main=get_tree().get_root().get_node("Main")
	if main:
		if explode_on_death:
			var explosion:Explosion=load("res://Scenes/General/explosion.tscn").instantiate()
			explosion.rubble_type=body.type
			explosion.player_damage=0
			explosion.global_position=body.global_position
			main.call_deferred("add_child",explosion)
		else:
			var corpse=load("res://Scenes/General/corpse.tscn").instantiate()
			corpse.global_position=body.global_position
			corpse.type=body.type
			main.call_deferred("add_child",corpse)
	body.queue_free()
