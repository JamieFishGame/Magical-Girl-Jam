class_name Player extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_player: AnimationPlayer = $"Attacks/Attack Player"
@onready var glass_pen: HitRay = $"Attacks/Glass Pen"
@onready var pen_tip: HitArea = $"Attacks/Glass Pen/Pen Tip"
@onready var attacks: Node2D = $Attacks
@onready var camera: mainCamera = $Camera2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitboxShape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var ray: RayCast2D = $Ray
var hud: Hud
const InkSplash = preload("uid://cfftqtx6gj1ak")
const InkBeam = preload("uid://dlwf58j85sf27")


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
var movementAvailable = true
var direction = 1
var movementDisable = 0
var Bumpable = 0
var manualBounce = false

var attackCooldown = 0
var attackChain = 0
var attackChainCooldown = 0
var penabled = false

var floatCooldown = 0

var slowTimer = 0
var slowStrength = 4

var projCount = 0
var projMax = 3

var iTimer = 0

var healCharge = 0
var healTime = 2
var healable = true

var slotDict = {
	"Weapon A": 0,
	"Weapon B": 1,
	"Weapon C": 2
	
	
}

var attackDict = {
	0:"Glass Pen Attack",
	1:"Brush Attack",
	2:"Stamp Attack"
}

var cooldownDict = {
	"Brush Attack2": 1,
	"Protractor Attack": .3,
	"Pencil Attack": .3,
	"Glass Pen Attack": 1,
	"Palette Attack": .5,
	"Stamp Attack": .5
	
	
}

var health = 5
var maxHealth = 5
var silver = 0

func _ready() -> void:
	Glob.camRef = camera
	Glob.playerRef = self
	if $"../Hud" != null:
		hud = $"../Hud"
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
		movementAvailable = true
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
	if Input.is_action_just_pressed("MovementAbility") and movementCooldown <= 0 and movementAvailable:
		#Warp(300)
		FloatDash(700)
		#ForwardDash(700) 
		movementAvailable = is_on_floor()
	
	
	if bounceTimer > 0:
		var collisionInfo = move_and_collide(velocity*delta, true)
		if collisionInfo and (floorBounce == (collisionInfo.get_normal() == Vector2.UP) or wallBounce == (collisionInfo.get_normal() != Vector2.UP)) and !manualBounce > (jumpBuffer > 0):
			var bumpSpeed = velocity.length()
			velocity = velocity.bounce(collisionInfo.get_normal()) * bounceDecay
			if Bumpable > 0:
				movementDisable = .3
				#direction  *= -1
				floatCooldown = 0
				camera.CamShake(bumpSpeed/30.0,Vector2.ZERO,collisionInfo.get_normal())
		bounceTimer -= delta
	if Bumpable > 0:
		Bumpable -= delta
	
	if attackCooldown <= 0 and !attack_player.is_playing():
		for action in slotDict.keys():
			if Input.is_action_pressed(action):
				var idx = slotDict[action]
				var anim = attackDict[idx]
				if anim == "Brush Attack":
					anim = anim + str(attackChain)
				
				attack_player.play(anim)
	else:
		attackCooldown -= delta
	GlassPen()
	if attackChainCooldown > 0:
		attackChainCooldown -= delta
	elif attackChainCooldown < 0:
		attackChain = 0
	
	if iTimer > 0:
		iTimer -= delta
	elif iTimer < 0:
		for area in hitbox.get_overlapping_areas():
			iTimer = 0
			if area is HitArea:
				_on_hitbox_area_entered(area)
	
	if slowTimer > 0:
		velocity -= velocity * slowStrength * delta
		slowTimer -= delta
	
	if Input.is_action_just_released("Heal"):
		healable = true
	if Input.is_action_just_pressed("Heal") and is_on_floor():
		velocity += Vector2.UP * 50
	if Input.is_action_pressed("Heal") and healable:
		healCharge += delta
		slowStrength = 2.5
		slowTimer = delta
		floatCooldown = delta
		movementDisable = delta
	else:
		healCharge = 0
	if healCharge >= healTime:
		print("HEAL")
		healable = false
		healCharge = 0
		health = maxHealth
		camera.CamShake(30)
		
	move_and_slide()

func ForwardDash(strength):
	iTimer = .3
	movementCooldown = .5
	velocity.x = strength * direction
	bounceTimer = .2
	bounceDecay = .3
	Bumpable = .2
	floorBounce = false
	wallBounce = true
	manualBounce = false
	slowTimer = 0
	
	velocity.y = 0
	floatCooldown = .2
	jumping = false
	
func FloatDash(strength):
	iTimer = .3
	movementCooldown = .5
	velocity.x = strength * direction
	bounceTimer = .2
	bounceDecay = .3
	Bumpable = .2
	floorBounce = false
	wallBounce = true
	manualBounce = false
	slowTimer = 0
	
	velocity.y = 0
	floatCooldown = .1
	jumping = false
	var diagonal = Vector2(direction,-.8).normalized()
	velocity = strength * diagonal

func Warp(strength=0):
	movementDisable = .3
	floatCooldown = .2
	movementCooldown = 2
	jumping = false
	velocity.y = 0
	ray.target_position = Vector2(direction,0) * strength
	ray.force_raycast_update()
	if ray.is_colliding():
		position = ray.get_collision_point()
	else:
		position = ray.global_position + ray.target_position

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
		proj.playerRef = self
		print(proj.direction)
		add_sibling(proj)
		projCount += 1

func OnHitEnemy(area:Area2D):
	if area.find_parent("Player") != null:
		if !is_on_floor():
			velocity.y = -100
			floatCooldown = .5
			movementAvailable = true
		slowTimer = .5
		slowStrength = 5
		
		
		for collider in area.get_children():
			
			if collider is CollisionShape2D:
				collider .set_deferred("disabled",true)

func GlassPen():
	if glass_pen.enabled and penabled:
		glass_pen.force_raycast_update()
		if glass_pen.is_colliding():
			var point = glass_pen.get_collision_point()
			pen_tip.global_position = point
			InkSpawn(point,glass_pen.get_collision_normal().angle())
			if !glass_pen.get_collider() is DamageControl:
				camera.CamShake(10,point)
		
		var beamInst: Line2D = InkBeam.instantiate()
		if glass_pen.is_colliding():
			beamInst.global_position = glass_pen.get_collision_point()
		else: 
			beamInst.global_position = glass_pen.to_global(glass_pen.target_position)
		beamInst.add_point(beamInst.to_local(global_position))
		add_sibling(beamInst)
	
		
		penabled = false
		
	
		
	
func InkSpawn(pos: Vector2,angle: float):
	
	var inkInst: GPUParticles2D = InkSplash.instantiate()
	inkInst.global_position = pos
	inkInst.rotation = angle
	add_sibling(inkInst)
	inkInst.emitting = true


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HitArea:
		if iTimer <= 0:
			healable = false
			healCharge = 0
			movementDisable = 1
			health -= 1
			area.disableTimer = 2
			iTimer = 2
			hud.vhsTimer = .1
			var enemy = area.get_parent()
			var velo: Vector2
			if enemy is CharacterBody2D:
				if enemy.velocity == Vector2.ZERO:
					velocity = Vector2.UP
				else:
					velocity = enemy.velocity * 1.5
			else:
				velocity = Vector2.UP
			velocity = velocity.normalized() * clampf(velocity.length(), 500, 2000)
			
			camera.CamShake(30,Vector2.ZERO,velocity.normalized())
	elif area is silver:
		silver += area.amount
		area.queue_free()
