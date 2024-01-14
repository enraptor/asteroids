extends Node2D


@export_category("Game settings")
@export var starting_lives = 3
@export var starting_asteroids = 2
@export var asteroid_spawn_range_min = 100
@export var asteroid_spawn_range_max = 300

@export_category("Pickups")
@export var drop_rate = 100
@export var max_drops = 2
@export var drops : Array[PickupResource]

var player_scene = preload("res://Assets/Scenes/player.tscn")
var asteroid_scene = preload("res://Assets/Scenes/asteroid_LG.tscn")
var explosion_scene = preload("res://Assets/Scenes/explosion.tscn")
var pickup_scene = preload("res://Assets/Scenes/pickup.tscn")

@onready var viewport_size = get_viewport().size

var player
var score = 0
var high_score = 0
var gameover = false
var level = 1
var level_clear = false
var drops_remaining
var current_lives
var asteroids_group = []

func _ready():
	start_new_game()
		
func _process(delta):
	asteroids_group = get_tree().get_nodes_in_group("Asteroids")
	%Asteroids/Value.text = str(asteroids_group.size())
	
	if gameover and Input.is_action_just_pressed("new game"):
		start_new_game()
	else:
		if asteroids_group.size() <= 0  and level_clear == false:
			level_cleared()
		
func start_new_game():
	# clear any asteroids
	clear_asteroids()
	score = 0
	level = 0
	current_lives = starting_lives
	gameover = false
	$GameOver.visible = false
	setup_new_level()
	
func setup_new_level():
	level += 1
	# scale the number of asteroids by level, slowly increasing difficulty
	var x = float(pow(level*2,0.6))
	var num_asteroids = x
	drops_remaining = max_drops
	$LevelCleared.visible = false
	$GameOver.visible = false
	%Health/Value.text = str(current_lives)
	spawn_player()
	for i in num_asteroids:
		spawn_asteroid()
	level_clear = false	

func level_cleared():
	$LevelCleared.visible = true
	$LevelCleared/Label.text = "Level " + str(level) + " Cleared!"
	level_clear = true
	player.queue_free()
	$RespawnTimer.start()
		
func clear_asteroids():
	for i in asteroids_group:
		i.queue_free()

func on_asteroid_hit(a):
	score += 1
	%Score/Value.text = str(score)
	if drops_remaining > 0:
		spawn_pickup(a.global_position)
		
func on_player_died():	
	current_lives -= 1
	%Health/Value.text = str(current_lives)
	
#	// blow up the ship
	spawn_explosion(player.transform)
	
	if current_lives <= 0:
		gameover = true
		$GameOver.visible = true
		if score > high_score:
			display_high_score()
		else:
			hide_high_score()
		player.queue_free()
	else:
		player.queue_free()
		$RespawnTimer.start()

func display_high_score():
	high_score = score
	$GameOver/VBoxContainer/HighScore.visible = true

func hide_high_score():
	$GameOver/VBoxContainer/HighScore.visible = false
	
func _on_respawn_timer_timeout():
	$RespawnTimer.stop()
	if level_clear:
		setup_new_level()
	else:
		spawn_player()

func spawn_player():
	player = player_scene.instantiate()
	player.transform.origin =  get_viewport().size / 2.0
	player.died.connect(on_player_died)
	add_child(player)
	player.owner = self
	
func spawn_asteroid():
	var spawn = viewport_size/2.0 + (Utilities.RandomUnitVector2() * randf_range(asteroid_spawn_range_min, asteroid_spawn_range_max))
	var a = asteroid_scene.instantiate()
	a.hit.connect(on_asteroid_hit)
	add_child(a)
	a.position = spawn
	
func spawn_pickup(spawn_location):
	if can_drop_item():
		drops_remaining -= 1
		var p = pickup_scene.instantiate()
		p.add_to_group("pickups")
		p.global_position = spawn_location
		var random_drop = randi_range(0,drops.size()-1)
		p.start(drops[random_drop], self)
		add_child(p)

func spawn_explosion(location : Transform2D):
	var e = explosion_scene.instantiate()
	e.transform = location
	add_child(e)

func can_drop_item():
	return randi()%100 <= drop_rate and get_tree().get_nodes_in_group("pickups").size() <= 0
	
# PICKUP EFFECTS
func add_score(points):
	score += points
	%Score/Value.text = str(score)
	
func add_life(lives_to_add):
	current_lives += lives_to_add
	%Health/Value.text = str(current_lives)
