extends Area2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _on_body_entered(_body: Node2D) -> void:
	SignalManager.coin_pickup.emit()
	
	anim.play("pickup")
	
	# إخفاء الهدية فورًا من اللعبة
	sprite.visible = false
	collision.disabled = true
	
	await get_tree().create_timer(0.1).timeout
	queue_free()
