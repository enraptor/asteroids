extends Node2D

func _ready():
	$Explode.pitch_scale = randi_range(-2.0,2.0)
	$Explode.play()

func _on_explode_finished():
	queue_free()
