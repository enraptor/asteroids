extends RigidBody2DWrap

var max_health = 1
var health = 1
var invulnerable = false

var rotation_speed = TAU
var thrust_force = 400

signal hit(player)
signal died

@export var bullet: PackedScene
@export var weapon_scenes: Array[PackedScene]
@onready var thrust_sprite = $Thrust

var invuln_timer 
var invuln_remaining  = 0
var has_shot = false
var thrusting = false
var weapon

var fire_cooldown_remaining = 0.0
var fire_cooldown = 0.25


func _ready():	
	attach_weapon(0)
	invuln_timer = $InvulnerabilityTimer
	invuln_timer.timeout.connect(_on_invulnerability_timeout)
	health = max_health
	thrust_sprite.visible = false 
	# Player starts in an invulnerable state
	start_invulnerability(1)

func attach_weapon(index):
	if weapon:
		remove_child(weapon)
	if weapon_scenes != null:
		weapon = weapon_scenes[index].instantiate()
		add_child(weapon)

func _on_invulnerability_timeout():
	# end invulnerability
	end_invulnerability()

func start_invulnerability(seconds):
	invuln_remaining += seconds
	if not invulnerable:
		invulnerable = true
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimationPlayer.play("invulnerable")
	
func end_invulnerability():
	invuln_remaining  -= 1
	if invuln_remaining > 0:
		$AnimationPlayer.stop()
		$AnimationPlayer.play()
	else:
		invulnerable = false		
		$CollisionShape2D.set_deferred("disabled", false)

func _process(delta):
	fire_cooldown_remaining -= delta
	if fire_cooldown_remaining <= 0 and Input.is_action_pressed("fire"):
		fire_cooldown_remaining = fire_cooldown
		shoot()
	if health <= 0:
		died.emit()
	
func _physics_process(delta):
	angular_velocity = 0
	if Input.is_action_pressed("rotate_cw"):
		angular_velocity = rotation_speed
	if Input.is_action_pressed("rotate_ccw"):
		angular_velocity = -rotation_speed
	if Input.is_action_pressed("forward"):
		apply_force(Vector2.UP.rotated(rotation) * thrust_force)
		thrust_sprite.visible = true 
		if $ThrustSound.is_playing() == false:
			$ThrustSound.play()
	if Input.is_action_just_released("forward"):
		thrust_sprite.visible = false 
		if $ThrustSound.is_playing():
			$ThrustSound.stop()
		
func shoot():
	$ShootSound.play()
	weapon.shoot()

func _on_body_entered(body):
	if invulnerable:
		return
	if body.has_method("damage") and body.exploding == false:
		body.damage()
	hit.emit(self)
	$HitSound.play()
	health -= 1
