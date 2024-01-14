extends Area2D


var resource
var game
var time_remaining = 0
var active = false

func _ready():
	pass
	
func start(res, game):
	self.game = game
	self.resource = res
	time_remaining = resource.timeout
	$Sprite2D.texture = resource.texture
	active = true

func _physics_process(delta):
	if active:
		time_remaining -= delta
		if time_remaining <= 0:
			queue_free()

func _on_pickup_sound_finished():
	queue_free()

func _on_body_entered(body):
	$Sprite2D.modulate = Color.BURLYWOOD
	match(resource.effect):
		"invuln":
			apply_invuln_pickup(body)
		"extralife":
			apply_extralife_pickup(body)
		"score":
			apply_score_pickup(body)
		"doublelaser":
			apply_doublelaser_pickup(body)
	complete_pickup()

func complete_pickup():
	$Sprite2D.visible = false
	$AudioStreamPlayer2D.stream = resource.pickup_sound
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D.finished.connect(_on_pickup_sound_finished)
		
func apply_invuln_pickup(body):
	if body.has_method("start_invulnerability"):
		body.start_invulnerability(3)

func apply_score_pickup(body):
	$Sprite2D.visible = false
	$AudioStreamPlayer2D.stream = resource.pickup_sound
	$AudioStreamPlayer2D.play()
	$AudioStreamPlayer2D.finished.connect(_on_pickup_sound_finished)
	game.add_score(10)
	pass

func apply_extralife_pickup(body):
	game.add_life(1)
	pass
	
func apply_doublelaser_pickup(body):
	body.attach_weapon(1)
	pass
