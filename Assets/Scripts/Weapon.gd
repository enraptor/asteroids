extends Node2D

@export var projectile_scene : PackedScene

func _ready():
	$ShipTemplate.visible = false

func shoot():
	var turrets = get_tree().get_nodes_in_group("Turret")
	for t in turrets:
		var b = projectile_scene.instantiate()
		b.transform = t.global_transform
		get_tree().root.add_child(b)
