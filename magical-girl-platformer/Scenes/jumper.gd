extends CharacterBody2D

@export var jumpStrength = 500
@export var range = 1200
@export var activeRange = 500
var active = false
var cooldown = 2
@onready var player = Glob.playerRef
func _physics_process(delta: float) -> void:
	if player.global_position.distance_to(global_position) < activeRange:
		active = true
	
	if active:
		if cooldown > 0:
			cooldown -= delta
		elif global_position.distance_to(player.global_position) < range:
			var angle = global_position.direction_to(player.global_position).angle()
			angle = lerp_angle(angle,-PI/2.0,.5)
			var dirVec = Vector2.from_angle(angle)
			
			velocity = jumpStrength * dirVec
			
			cooldown = 3
		
		move_and_slide()
		if is_on_floor():
			velocity = velocity.move_toward(Vector2.ZERO,10)
		else:
			velocity += get_gravity() * delta
			
		var collisionInfo = move_and_collide(velocity*delta, true)
		if collisionInfo:
			if abs(collisionInfo.get_normal().y) < .5:
				velocity = velocity.bounce(collisionInfo.get_normal()) * .7
