extends RigidBody2DWrap

@export var explosion: PackedScene
@export var debris : PackedScene
@export var debris_amount = 2
@export var pickup = preload("res://Assets/Scenes/pickup.tscn")

signal hit(asteroid)

var rotation_speed = TAU
var exploding = false
var starting_impulse = 200

func _ready():
	add_to_group("Asteroids")
	rotation_speed = randf_range(0,TAU/4)
	apply_impulse(Utilities.RandomUnitVector2() * randf_range(starting_impulse/2, starting_impulse*2))


func _physics_process(delta):
	angular_velocity = rotation_speed
	pass
	
func damage():
	if debris:
		for i in debris_amount:
			var d = debris.instantiate()
			d.global_position = self.global_position
			get_parent().add_child(d)
			d.hit.connect(get_parent().on_asteroid_hit)
	var e = explosion.instantiate()
	e.transform = transform
	get_parent().add_child(e)
	hit.emit(self)
	queue_free()

