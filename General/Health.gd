extends Node
class_name Health

@export var maxhp:float=-1
@export var hurtbox: Hurtbox
@export var has_popups=true
var hp=maxhp
var prevhp=hp
var recent_hplost=0
var main
var timer:Timer
signal took_damage(damage)
signal hpchanged
signal hplost
signal dead

func _ready():
	main=get_tree().get_root().get_node("Main")
	if hp==-1:
		hp=maxhp
		prevhp=maxhp
	if hurtbox:
		hurtbox.take_hit.connect(take_damage)
	timer=Timer.new()
	timer.wait_time=0.05
	if has_popups:
		timer.timeout.connect(make_popup)
	timer.one_shot=true
	add_child(timer)
	

func set_max(new_max):
	maxhp=new_max
	if hp>maxhp:
		hp=maxhp
	prevhp=hp

func heal():
	if hp!=maxhp:
		hp=maxhp
		prevhp=hp
		hpchanged.emit()
		$Rally.play()

func rally():
	if hp!=prevhp:
		$Rally.play()
		hp=prevhp
		hpchanged.emit()

func take_damage(attack, parry=false):
	if hp<=0 or (attack.name=="Fall" and hp<=1):
		return
	prevhp=hp
	hp-=attack.damage
	if parry:
		hp-=attack.damage
	if not parry:
		took_damage.emit()
	if Global.load_config("game","damage_values") and timer.is_stopped() and not get_parent() is Player:
		timer.start()
	recent_hplost+=prevhp-hp
	
	hp=max(0,hp)
	#if attack.targetparent is Player:
		#var bypass=hp<=0 and not get_parent() is Corpse
		#attack.targetparent.control.speed_boost(bypass)
	hplost.emit(hp<=0)
	hpchanged.emit()
	if hp<=0:
		dead.emit()
		hurtbox.disable_hurtbox()
		if has_popups:
			make_popup()

func set_hp(new_hp):
	hp=new_hp
	prevhp=hp
	hpchanged.emit()
	
func make_popup():
	if recent_hplost==0:
		return
	var popup=load("res://Scenes/Particles/damage_popup.tscn").instantiate()
	popup.damage=recent_hplost
	main.add_child(popup)
	popup.global_position=hurtbox.global_position+Vector2.UP*24
	recent_hplost=0
