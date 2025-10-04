extends Area2D
class_name SearchField

@onready var collision_shape=$CollisionShape2D
@onready var ray=$ViewRayCast
@export var radius=128
@export var see_through_walls=false

func _ready():
	collision_shape.shape.radius=radius

func raytarget(pos):
	ray.target_position=pos-global_position
	ray.force_raycast_update()

func find_body():
	var bodies=get_overlapping_areas()
	if bodies:
		var potentialtarget=bodies[0].get_parent()
		if len(bodies)>1:
			var bodydists={}
			for body in bodies:
				if body.get_parent() is CharacterBody2D:
					var dist=global_position.distance_squared_to(body.get_parent().global_position)
					if body.get_parent() is RolyPoly or body.get_parent() is Player:
						dist=sqrt(dist)
					bodydists[dist]=body.get_parent()
			potentialtarget=bodydists[bodydists.keys().min()]
		raytarget(potentialtarget.global_position)
		if see_through_walls or not ray.is_colliding():
			return potentialtarget
	return null

func found():
	if find_child("Spotted"):
		$Spotted.emitting=true
	if find_child("SFXSpotted"):
		$SFXSpotted.play()

func nearby_count(max_dist=40):
	var turn_off
	if !monitoring:
		turn_off=true
	monitoring=true
	var bodies=get_overlapping_areas()
	var res=0
	if bodies:
		max_dist=max_dist*max_dist
		for body in bodies:
			var dist=global_position.distance_squared_to(body.get_parent().global_position)
			if dist<max_dist:
				res+=1
	if turn_off:
		monitoring=false
	return res
