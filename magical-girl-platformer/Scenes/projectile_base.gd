class_name projectile extends CharacterBody2D

var direction := Vector2(1,0)
var player: Player

func _process(delta: float) -> void:
	move_and_slide()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		player.projCount -= 1
