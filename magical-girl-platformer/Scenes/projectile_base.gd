class_name projectile extends CharacterBody2D

var direction := Vector2(1,0)
var playerRef: Player
@export var playerProj = true
@export var collideDestroy  = true
func _physics_process(delta: float) -> void:
	if collideDestroy:
		var collision = move_and_collide(velocity*delta,true)
		if collision != null:
			queue_free()
	
	
	move_and_slide()
	
	



func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and playerProj:
		playerRef.projCount -= 1
