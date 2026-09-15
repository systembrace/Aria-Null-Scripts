extends Node
class_name Knockback

@export var hurtbox: Hurtbox
@export var health: Health
@export var hitstun: Hitstun
@export var self_kb_combo: Combo
@export var knockback_modifier=1.0
@export var combo_unstoppable:Combo
@export var death_const_mod=false
@export var inc_mod_on_stun=false
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
	if self_kb_combo:
		self_kb_combo.hit_hurtbox.connect(self_knockback)
		self_kb_combo.just_parried.connect(parried)
	
func stun():
	stunned=true
	
func dead_knockback():
	dead=true

func parried(parried_attack,attack):
	take_knockback(attack,parried_attack,true)

func self_knockback(hurtbox_parent,attack):
	if hurtbox_parent is Enemy:
		take_knockback(attack,null,true)

func take_knockback(area, parry_reciever:Hitbox=null,self_kb=false):
	if !stunned and !dead and !self_kb and parry_reciever is Attack and parry_reciever.redirect_when_parried:
		get_parent().velocity=get_parent().velocity.length()*area.knockback_vector(get_parent().global_position).normalized()
		parry_reciever.look_at(get_parent().velocity)
		return
	if combo_unstoppable and !combo_unstoppable.current_attack.allow_knockback and combo_unstoppable.is_damaging():
		return
	effect_mod=1
	if dead and death_const_mod:
		if area.targetparent is Bullet or area.targetparent is Harpoon:
			get_parent().velocity=Vector2.ZERO
			return
		knockback_modifier=-125
	if stunned or dead or area.targetparent is Earthshaker:
		effect_mod=2
		if stunned and knockback_modifier<1 and inc_mod_on_stun:
			effect_mod*=1.5
		stunned=false
		dead=false
	if area.damage>1:
		effect_mod+=min(area.damage/4,1)
	var kb_velocity=Vector2.ZERO
	if knockback_modifier>0:
		kb_velocity=area.knockback_vector(get_parent().global_position)*knockback_modifier*effect_mod
	else:
		kb_velocity=area.knockback_vector(get_parent().global_position).normalized()*-knockback_modifier*effect_mod
	if self_kb:
		if parry_reciever and parry_reciever.heavy:
			get_parent().velocity=-kb_velocity*.75
		else:
			get_parent().velocity-=kb_velocity*.25
	else:
		get_parent().velocity=kb_velocity
