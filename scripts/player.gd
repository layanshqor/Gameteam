extends CharacterBody2D
class_name Player

@onready var death_timer: Timer = $DeathTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audioPlayer: AnimationPlayer = $AudioPlayerController
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hitbox: CollisionShape2D = $StompArea/CollisionShape2D

const ACCELERATION: float = 1300.0
const MAX_HORIZONTAL_SPEED: float = 120.0
const JUMP_VELOCITY = -300.0
const BOUNCE_VELOCITY = -200.0

var dead: bool = false
var hit: bool = false
var health: int = 5
var last_direction: int = 1

func _ready() -> void:
	SignalManager.player_hit.connect(Callable(self, "on_player_hit"))
	SignalManager.player_health_ui_setup.emit(health)
	SignalManager.player_bounce.connect(Callable(self, "on_bounce"))

func _physics_process(delta: float) -> void:
	if velocity.y > 0:
		hitbox.disabled = false
	else:
		hitbox.disabled = true
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and (is_on_floor() or !coyote_timer.is_stopped()) and !dead:
		velocity.y = JUMP_VELOCITY
		audioPlayer.play("jump")
		coyote_timer.stop()

	var direction: int = get_direction()
	
	if direction and !dead:
		velocity.x += direction * ACCELERATION * delta
	else:
		velocity.x = lerp(0.0, velocity.x, pow(2, -25 * delta))
	
	velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)

	var was_on_floor = is_on_floor()
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	
	get_animation()

func get_direction() -> int:
	var dir: float = Input.get_axis("move_left", "move_right")
	var actual_direction = sign(dir)
	if (last_direction > 0 or last_direction < 0) and actual_direction == 0:
		last_direction = last_direction
	else:
		last_direction = actual_direction
	
	return actual_direction

func on_player_hit():
	if dead:
		return

	print("تمت إصابة اللاعب!")
	audioPlayer.play("hurt")
	SignalManager.camera_shake.emit()

	if health > 0:
		hit = true
		health -= 1
		print("العدد الحالي للقلوب: ", health)
		SignalManager.player_health_changed.emit(health)

	if health <= 0 and !dead:
		dead = true
		sprite.play("idle")  # مؤقت
		death_timer.start()

func _on_timer_timeout() -> void:
	SignalManager.player_died.emit()

func get_animation():
	var direction = get_direction()
	
	if hit:
		sprite.play("idle")  
	elif is_on_floor() and !dead:
		if direction == 0:
			sprite.play("idle")
		else:
			sprite.play("walk")
	elif !is_on_floor() and !dead:
		sprite.play("jump")

	if !dead:
		sprite.flip_h = direction < 0

func on_bounce():
	velocity.y = BOUNCE_VELOCITY
