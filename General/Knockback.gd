extends Node
class_name Knockback

@export var hurtbox: Hurtbox
@export var health: Health
@export var hitstun: Hitstun
@export var knockback_modifier=1.0
var dead=false
var effect_mod=1
var stunned=false

func _ready():
	if hurtbox:
		hurtbox.take_hit.connect(take_knockback)
	if health:
		health.dead.connect(dead_knockback)
	if hitstun:
		hitstun.stunned.connect(stun)
	
func stun():
	stunned=true
	
func dead_knockback():
	dead=true
	
func take_knockback(area, _parry=false):
	effect_mod=1
	if stunned or dead or area.targetparent is Earthshaker:
		effect_mod=2
		stunned=false
		dead=false
	if area.damage>1:
		effect_mod+=min(area.damage/4,1)
	get_parent().velocity=area.knockback_vector(get_parent().global_position)*knockback_modifier*effect_mod
