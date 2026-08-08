class_name Player extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_player: AnimationPlayer = $"Attacks/Attack Player"
@onready var glass_pen: HitRay = $"Attacks/Glass Pen"
@onready var pen_tip: HitArea = $"Attacks/Glass Pen/Pen Tip"
@onready var attacks: Node2D = $Attacks
@onready var camera: Camera2D = $Camera2D


var maxSpeed = 300.0
var gravMod = 1
var jumpVelocity = -300.0
var accel = 600
var dropSpeed = 150
var dropGrav = 2

var jumpHoldLength = .3
var jumpHold = 0

var bounceTimer = 0
var wallBounce = false
var floorBounce = false
var bounceDecay = .5

var jumpBufferLength = .8
var jumpBuffer = 0

var jumping = false
var movementCooldown = 0
var direction = 0
var movementDisable = 0
var Bumpable = 0
var manualBounce = false

var attackCooldown = 0
var attackChain = 0
var attackChainCooldown = 0

var floatCooldown = 0

var projCount = 0
var projMax = 6

var slotDict = {
	"Weapon A": 0,
	"Weapon B": 1,
	"Weapon C": 2
	
	
}

var attackDict = {
	0:"Protractor Attack",
	1:"Pencil Attack",
	2:"Glass Pen Attack"
}

var cooldownDict = {
	"Brush Attack2": 1,
	"Protractor Attack": .3,
	"Pencil Attack": .5,
	"Glass Pen Attack": 1,
	"Palette Attack": .5
	
	
}

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if gravMod < dropGrav and velocity.y > 0:
			gravMod = 1.5
		if Input.is_action_just_pressed("Down"):
			gravMod = dropGrav
			velocity.x = 0
			if velocity.y < dropSpeed:
				velocity.y = dropSpeed
		if floatCooldown <= 0:
			velocity += get_gravity() * gravMod * delta 
	if floatCooldown > 0:
		floatCooldown -= delta
	
	if jumpBuffer > 0:
		jumpBuffer -= delta
	if Input.is_action_just_pressed("Jump"):
		jumpBuffer = jumpBufferLength
	# Handle jump.
	if is_on_floor():
		gravMod = 1
		jumpHold = 0
		jumping = false
		
		if jumpBuffer > 0:
			jumpBuffer = 0
			jumping = true
			jumpHold = jumpHoldLength
			
		
		
	if Input.is_action_pressed("Jump") and jumping and jumpHold > 0:
		velocity.y = jumpVelocity
		jumpHold -= delta
	else:
		jumping = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if movementDisable <= 0:
		var axis = Input.get_axis("Left", "Right")
		if axis != 0:
			direction = ceil(abs(axis)) * sign(axis)
			
		if direction:
			var actualAccel = axis * accel * 4 * delta
			if abs(velocity.x + actualAccel) < maxSpeed:
				velocity.x += actualAccel
	else:
		movementDisable -= delta
	
	if floatCooldown <= 0:
		if is_on_floor() or sign(direction) != sign(velocity.x):
			velocity.x = move_toward(velocity.x, 0, accel * 2 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, accel * .5 * delta)
		if abs(velocity.x) > maxSpeed:
			velocity.x = move_toward(velocity.x, 0, accel * 3 * delta)
	
	if direction > 0:
		sprite.scale.x = abs(sprite.scale.x)
		attacks.scale.x = 1
	elif direction < 0:
		sprite.scale.x = -abs(sprite.scale.x)
		attacks.scale.x = -1
	
	if movementCooldown > 0:
		movementCooldown -= delta
	if Input.is_action_just_pressed("MovementAbility") and movementCooldown <= 0:
		ForwardDash(700) 
	
	
	if bounceTimer > 0:
		var collisionInfo = move_and_collide(velocity*delta, true)
		if collisionInfo and (floorBounce == (collisionInfo.get_normal() == Vector2.UP) or wallBounce == (collisionInfo.get_normal() != Vector2.UP)) and !manualBounce > (jumpBuffer > 0):
			velocity = velocity.bounce(collisionInfo.get_normal()) * bounceDecay
			if Bumpable > 0:
				movementDisable = .3
				#direction  *= -1
				floatCooldown = 0
		bounceTimer -= delta
	if Bumpable > 0:
		Bumpable -= delta
	
	if attackCooldown <= 0:# and !attack_player.is_playing()
		for action in slotDict.keys():
			if Input.is_action_pressed(action):
				var idx = slotDict[action]
				var anim = attackDict[idx]
				if anim == "Brush Attack":
					anim = anim + str(attackChain)
				
				attack_player.play(anim)
	else:
		attackCooldown -= delta
	if glass_pen.enabled:
		pen_tip.global_position = glass_pen.get_collision_point()
	
	if attackChainCooldown > 0:
		attackChainCooldown -= delta
	else:
		attackChain = 0
	
	
	move_and_slide()

func ForwardDash(strength):
	movementCooldown = .5
	velocity.x = strength * direction
	bounceTimer = .2
	bounceDecay = .3
	Bumpable = .2
	floorBounce = false
	wallBounce = true
	manualBounce = false
	
	velocity.y = 0
	floatCooldown = .2
	jumping = false
	
func WaveDash(strength):
	movementCooldown = 1
	var diagonal = Vector2(direction,.5).normalized()
	velocity = strength * diagonal
	bounceTimer = .5
	movementDisable = .5
	bounceDecay = .9
	floorBounce = true
	wallBounce = true
	manualBounce = true

func _on_attack_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in cooldownDict:
		attackCooldown = cooldownDict[anim_name]
	if anim_name == "Brush Attack0" or anim_name == "Brush Attack1":
		attackChain += 1
		print(attackChain)
		attackChainCooldown = .6

func Projectile(projRef:String):
	if projCount < projMax:
		var projScene = load(projRef)
		var proj: projectile = projScene.instantiate()
		proj.global_position = global_position
		proj.direction.x = direction
		proj.player = self
		print(proj.direction)
		add_sibling(proj)
		projCount += 1
