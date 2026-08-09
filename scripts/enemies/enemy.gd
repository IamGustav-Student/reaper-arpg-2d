extends CharacterBody2D
class_name Enemy
## IA mínima de enemigo: persigue al jugador dentro de detection_radius,
## ataca con su Hitbox cuando está en attack_range, y al morir
## (HealthSystem.died) suelta un Orbe de Alma y se elimina.

@export var soul_orb_scene: PackedScene
@export var soul_essence_drop: float = 15.0

@export var move_speed: float = 80.0
@export var detection_radius: float = 220.0
@export var attack_range: float = 40.0
@export var attack_cooldown: float = 1.5
@export var attack_duration: float = 0.2

@onready var health_system: HealthSystem = $HealthSystem
@onready var hitbox: Hitbox = $Hitbox

var _target: Node2D
var _attack_cooldown_timer: float = 0.0
var _attack_active_timer: float = 0.0
var _is_attacking: bool = false

func _ready() -> void:
	health_system.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	# Búsqueda perezosa en vez de una sola vez en _ready(): Player y los
	# enemigos son hermanos que se instancian a la vez, así que no hay
	# garantía de que Player ya esté en el grupo "player" cuando corre
	# el _ready() de este enemigo.
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

	_attack_cooldown_timer = max(0.0, _attack_cooldown_timer - delta)

	if _is_attacking:
		_attack_active_timer -= delta
		if _attack_active_timer <= 0.0:
			_is_attacking = false
			hitbox.set_active(false)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _target == null or not is_instance_valid(_target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_target := _target.global_position - global_position
	var distance := to_target.length()

	if distance <= attack_range:
		velocity = Vector2.ZERO
		if _attack_cooldown_timer <= 0.0:
			_start_attack(to_target.normalized())
	elif distance <= detection_radius:
		velocity = to_target.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _start_attack(direction: Vector2) -> void:
	_is_attacking = true
	_attack_active_timer = attack_duration
	_attack_cooldown_timer = attack_cooldown
	# hitbox.position es local al enemigo (que suele estar escalado x2-x3),
	# así que se compensa la escala para que el alcance quede en unidades de mundo.
	hitbox.position = direction * (attack_range * 0.5) / scale.x
	hitbox.set_active(true)

func _on_died() -> void:
	if soul_orb_scene:
		var orb: Node2D = soul_orb_scene.instantiate()
		orb.global_position = global_position
		orb.essence_amount = soul_essence_drop
		get_parent().add_child(orb)
	queue_free()
