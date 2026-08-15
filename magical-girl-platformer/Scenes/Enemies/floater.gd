extends CharacterBody2D

@export var projectileScene: PackedScene
@export var rechargeTime = 2
@export var noiseStrength = 10
@export var range = 100
@export var clamp = 5
@export var activeRange = 500
var recharge = 0
var player: Player

var active = false
var velo: Vector2
var offset: Vector2
func _ready() -> void:
	player = Glob.playerRef
	

func _physics_process(delta: float) -> void:
	if player.global_position.distance_to(global_position) < activeRange:
		active = true
	
	if active:
		if recharge > 0:
			recharge -= delta
		else:
			recharge = rechargeTime
			
			var newProj: projectile = projectileScene.instantiate()
			newProj.direction = global_position.direction_to(player.global_position)
			newProj.global_position = global_position
			add_sibling(newProj)


		var noiseX = randf_range(-1,1)
		var noiseY = randf_range(-1,1)
		
		
		velo.x += noiseStrength*noiseX * delta
		velo.y += noiseStrength*noiseY * delta
		offset.x += velo.x * delta
		offset.y += velo.y * delta
		offset = offset.clamp(Vector2(-clamp,-clamp),Vector2(clamp,clamp))
		
		var playerDir = global_position.direction_to(player.global_position)
		var target = player.global_position + -playerDir * range 
		global_position = lerp(global_position,target,delta/2) +offset
		velocity += playerDir * delta * global_position.distance_to(player.global_position)/100
		
		
		var collisionInfo = move_and_collide(velocity*delta, true)
		if collisionInfo:
			offset = offset.bounce(collisionInfo.get_normal()) * .7
			velo = velo.bounce(collisionInfo.get_normal()) * .7
		
		
		move_and_slide()
	
