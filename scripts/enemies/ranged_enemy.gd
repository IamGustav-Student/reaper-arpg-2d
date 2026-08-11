extends Enemy
class_name RangedEnemy
## Segundo tipo de amenaza (Hito 12): mantiene distancia del jugador y le
## arroja proyectiles en vez de perseguir para pegar cuerpo a cuerpo.
## Hereda de Enemy (HealthSystem/muerte/soltar alma reusados); reemplaza
## por completo la IA de movimiento/ataque de la clase base.

@export var projectile_scene: PackedScene
@export var preferred_range: float = 250.0
@export var projectile_speed: float = 260.0
@export var ranged_attack_cooldown: float = 2.0
@export var muzzle_offset: float = 45.0

var _ranged_cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")

	_ranged_cooldown_timer = max(0.0, _ranged_cooldown_timer - delta)

	if _target == null or not is_instance_valid(_target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_target := _target.global_position - global_position
	var distance := to_target.length()
	var direction := to_target.normalized()

	if distance < preferred_range * 0.7:
		velocity = -direction * move_speed  # muy cerca: retirarse
	elif distance > preferred_range * 1.3:
		velocity = direction * move_speed   # muy lejos: acercarse
	else:
		velocity = Vector2.ZERO
		if _ranged_cooldown_timer <= 0.0:
			_fire_projectile(direction)

	move_and_slide()

func _fire_projectile(direction: Vector2) -> void:
	_ranged_cooldown_timer = ranged_attack_cooldown
	if projectile_scene == null:
		return

	var projectile: Projectile = projectile_scene.instantiate()
	projectile.direction = direction
	projectile.speed = projectile_speed
	get_parent().add_child(projectile)
	projectile.global_position = global_position + direction * muzzle_offset
