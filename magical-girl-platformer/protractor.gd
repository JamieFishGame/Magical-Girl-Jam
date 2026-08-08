extends projectile

var pull = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity = direction * 500
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	velocity -= pull * (position - player.position) * delta
	move_and_slide()
	var collision = move_and_collide(velocity*delta,true)
	if collision != null:
		queue_free()
