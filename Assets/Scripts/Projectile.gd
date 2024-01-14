extends Area2D

@export var speed = 750

var velocity = Vector2.ZERO

func _physics_process(delta):
	position -= transform.y * speed * delta
	if position.x < 0 or position.x > get_viewport_rect().size.x or position.y < 0 or position.y > get_viewport_rect().size.y:
		queue_free()
	
func _on_body_entered(body):
	if body.has_method("damage") and body.exploding == false:
		body.damage()
		queue_free()
