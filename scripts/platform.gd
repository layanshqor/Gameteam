extends AnimatableBody2D

@onready var ray_cast_up: RayCast2D = $RayCastRight
@onready var ray_cast_down: RayCast2D = $RayCastLeft
@onready var waiting_timer: Timer = $WaitingTimer

@export var platform_waiting_time: float = 1.0
@export var speed: float = 60

var moveable: bool = true
var direction: int = 1  # 1 = تحت، -1 = فوق

func _ready() -> void:
	waiting_timer.wait_time = platform_waiting_time

func _physics_process(delta: float) -> void:
	if moveable:
		position.y += direction * speed * delta
	
	if ray_cast_down.is_colliding() and moveable:
		start_waiting()
		ray_cast_down.enabled = false
		ray_cast_up.enabled = true
		direction = -1  # ابدأ التحرك لأعلى
		
	if ray_cast_up.is_colliding() and moveable:
		start_waiting()
		ray_cast_down.enabled = true
		ray_cast_up.enabled = false
		direction = 1  # ابدأ التحرك لأسفل

func start_waiting():
	waiting_timer.start()
	moveable = false if moveable == true else true

func _on_waiting_timer_timeout() -> void:
	moveable = true
