extends StaticBody2D
@onready var damage_area: Area2D = $DamageArea
var can_damage: bool = true
var damage_cooldown: float = 1.0

func _ready():
	damage_area.body_entered.connect(on_body_entered)

func on_body_entered(body):
	if body is Player and can_damage:
		can_damage = false
		SignalManager.player_hit.emit()
		await get_tree().create_timer(damage_cooldown).timeout
		can_damage = true
	
