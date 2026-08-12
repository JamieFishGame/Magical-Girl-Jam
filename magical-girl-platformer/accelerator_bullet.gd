extends projectile

var time = 0
@export var startingSpeed = 10
@export var Base = 4
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	var speed = startingSpeed*pow(Base,time)
	velocity = direction * speed
	if velocity.length() > 2000:
		queue_free()
