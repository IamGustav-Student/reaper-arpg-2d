extends Enemy
class_name BossTreant
## Primer World Boss (GDD 6.2 / docs/ENEMY_AND_BOSS_PROGRESSION_PLAN.md).
## Fase 1 (100%-50% HP): solo el ataque cuerpo a cuerpo heredado de Enemy.
## Transición (cruce de 50%): invulnerable + flash sostenido 1.5s.
## Fase 2 (50%-0%): suma un ataque de área telegrafiado sobre el jugador.

@export var telegraph_scene: PackedScene
@export var transition_invuln_duration: float = 1.5
@export var aoe_cooldown: float = 4.0
@export var aoe_active_duration: float = 0.25

@onready var boss_hurtbox: Hurtbox = $Hurtbox
@onready var aoe_hitbox: Hitbox = $AoEHitbox
@onready var sprite: Sprite2D = $Sprite2D

var _phase: int = 1
var _in_transition: bool = false
var _aoe_cooldown_timer: float = 0.0

func _ready() -> void:
	super._ready()
	health_system.health_changed.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	if _in_transition:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	super._physics_process(delta)

	if _phase != 2:
		return

	_aoe_cooldown_timer = max(0.0, _aoe_cooldown_timer - delta)
	if _aoe_cooldown_timer <= 0.0 and _target and is_instance_valid(_target):
		_start_aoe_attack()

func _on_health_changed(current: float, max_value: float) -> void:
	if _phase == 1 and current <= max_value * 0.5:
		_start_phase_transition()

func _start_phase_transition() -> void:
	_phase = 2
	_in_transition = true
	boss_hurtbox.set_invulnerable(true)
	if sprite.material:
		sprite.material.set_shader_parameter("flash_amount", 1.0)

	await get_tree().create_timer(transition_invuln_duration).timeout

	if sprite.material:
		sprite.material.set_shader_parameter("flash_amount", 0.0)
	boss_hurtbox.set_invulnerable(false)
	_in_transition = false
	_aoe_cooldown_timer = 1.0  # respiro antes del primer Pisotón Sísmico

func _start_aoe_attack() -> void:
	_aoe_cooldown_timer = aoe_cooldown
	if telegraph_scene == null:
		return

	var telegraph: TelegraphArea = telegraph_scene.instantiate()
	var target_position: Vector2 = _target.global_position
	telegraph.global_position = target_position
	get_parent().add_child(telegraph)

	await telegraph.telegraph_finished

	if not is_instance_valid(self):
		return

	aoe_hitbox.global_position = target_position
	aoe_hitbox.set_active(true)
	await get_tree().create_timer(aoe_active_duration).timeout
	if is_instance_valid(aoe_hitbox):
		aoe_hitbox.set_active(false)
