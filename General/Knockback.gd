extends Node
class_name Knockback

@export var hurtbox: Hurtbox
@export var health: Health
@export var hitstun: Hitstun
@export var knockback_modifier=1.0
@export var combo_unstoppable:Combo
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
	
func take_knockback(area, parry_reciever:Hitbox=null):
	if !stunned and !dead and parry_reciever is Attack and parry_reciever.redirect_when_parried:
		get_parent().velocity=get_parent().velocity.length()*area.knockback_vector(get_parent().global_position).normalized()
		parry_reciever.look_at(get_parent().velocity)
		return
	if combo_unstoppable and !combo_unstoppable.current_attack.allow_knockback and combo_unstoppable.is_damaging():
		return
	effect_mod=1
	if stunned or dead or area.targetparent is Earthshaker:
		effect_mod=2
		stunned=false
		dead=false
	if area.damage>1:
		effect_mod+=min(area.damage/4,1)
	if knockback_modifier>0:
		get_parent().velocity=area.knockback_vector(get_parent().global_position)*knockback_modifier*effect_mod
	else:
		get_parent().velocity=area.knockback_vector(get_parent().global_position).normalized()*-knockback_modifier*effect_mod
