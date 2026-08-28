extends CharacterBody2D
@onready var ray: RayCast2D = $Flip/RayCast2D
@onready var flip: Node2D = $Flip

@export var speed = 10
var dir = 1
var wallHittable = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.x = dir * speed
	flip.scale.x = dir
	if !is_on_floor():
		velocity += get_gravity() * delta
	if is_on_wall() or !ray.is_colliding():
		if wallHittable:
			dir *= -1
			velocity.x = dir * speed
			wallHittable = false
	else:
		wallHittable = true
	move_and_slide()
	
