extends CharacterBody2D
class_name Player
## Controlador del jugador: movimiento 4-direccional, Dash con i-frames
## (GDD sección 3.2), ataque básico cuerpo a cuerpo y animaciones
## direccionales (idle/walk/attack x front/back/side, side se espeja con
## flip_h para izquierda/derecha).

@export var move_speed: float = 260.0
@export var dash_speed: float = 950.0
@export var dash_duration: float = 0.22       # ~13 frames a 60 fps
@export var dash_cooldown: float = 1.2
@export var iframe_start_ratio: float = 0.15  # equivalente a frame ~2 de 13
@export var iframe_end_ratio: float = 0.9     # equivalente a frame ~12 de 13

@export var attack_duration: float = 0.25     # 3 frames de ataque a 12 fps
@export var attack_range_offset: float = 26.0
@export var base_attack_data: AttackData = preload("res://resources/attacks/basic_sword.tres")

## Hito 13: Runas de Desencadenante (Soul-Crafting) casteadas fuera del
## swing manual del Player — nunca reusan `hitbox` para no pisar su máquina
## de estados de ataque (que puede estar activa o no cuando el trigger salta).
const SPECTRAL_PROJECTILE_SCENE: PackedScene = preload("res://scenes/combat/spectral_projectile.tscn")
const SPELL_BURST_SCENE: PackedScene = preload("res://scenes/combat/spell_burst.tscn")

@onready var hurtbox: Hurtbox = $Hurtbox
@onready var stats: StatSystem = $StatSystem
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var health_system: HealthSystem = $HealthSystem

var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.DOWN
var _is_dashing: bool = false

var _attack_timer: float = 0.0
var _is_attacking: bool = false

func _ready() -> void:
	add_to_group("player")
	health_system.died.connect(_on_died)
	hitbox.critical_hit_landed.connect(_on_critical_hit_landed)

## Sin pantalla de game over todavía: reinicia el nivel al morir.
func _on_died() -> void:
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)

	if _is_attacking:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_is_attacking = false
			hitbox.set_active(false)

	if _is_dashing:
		_process_dash(delta)
	else:
		_process_movement()

	if Input.is_action_just_pressed("attack_light") and not _is_attacking and not _is_dashing:
		_start_attack()

	move_and_slide()

func _process_movement() -> void:
	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input_dir * move_speed * stats.move_speed_mult

	if input_dir != Vector2.ZERO:
		_dash_direction = input_dir

	if Input.is_action_just_pressed("dash") and _dash_cooldown_timer <= 0.0:
		_start_dash()
		return

	if not _is_attacking:
		_update_animation(input_dir != Vector2.ZERO)

func _start_dash() -> void:
	_is_dashing = true
	_dash_timer = 0.0
	_dash_cooldown_timer = dash_cooldown

	# Runa de Desencadenante "Al Esquivar" (Hito 13): si el Slot de Movilidad
	# la tiene equipada, cada Dash también lanza lo que esté crafteado ahí.
	if RuneAltarManager.has_dodge_trigger("mobility"):
		var composed := RuneAltarManager.get_composed_attack_data(base_attack_data, "mobility")
		_cast_trigger_spell(composed, _dash_direction)

func _process_dash(delta: float) -> void:
	_dash_timer += delta
	var t := _dash_timer / dash_duration

	velocity = _dash_direction * dash_speed

	var in_iframe_window := t >= iframe_start_ratio and t <= iframe_end_ratio
	hurtbox.set_invulnerable(in_iframe_window)

	if not _is_attacking:
		_update_animation(true)

	if t >= 1.0:
		_is_dashing = false
		hurtbox.set_invulnerable(false)

## Craftea el ataque real a partir de lo que esté equipado en el Slot Activo
## (Soul-Crafting, GDD 3.4 / Hito 8). Sin runas equipadas, se comporta
## exactamente igual que antes (usa base_attack_data sin cambios). Si la
## Runa de Forma "Proyectil Espectral" está equipada (Hito 13), el golpe se
## lanza a distancia en vez de activar el Hitbox cuerpo a cuerpo del Player.
func _start_attack() -> void:
	_is_attacking = true
	_attack_timer = attack_duration
	animated_sprite.flip_h = _dash_direction.x < 0
	animated_sprite.play("attack_" + _facing_from_direction(_dash_direction))

	var composed := RuneAltarManager.get_composed_attack_data(base_attack_data, "active")
	if composed.is_projectile:
		_fire_projectile_spell(composed, _dash_direction)
	else:
		hitbox.position = _dash_direction * attack_range_offset
		hitbox.attack_data = composed
		hitbox.set_active(true)

## Runa de Desencadenante "Al Asestar Crítico" (Hito 13): si el Slot Activo
## la tiene equipada, cada crítico conectado con el ataque manual relanza lo
## crafteado ahí. No puede recursar: el relanzamiento usa un SpellBurst/
## Projectile suelto (nunca `hitbox`), así que su propio critical_hit_landed
## no está conectado a nada.
##
## Este signal puede llegar desde Hitbox._on_area_entered, que corre DENTRO
## del flush de queries del motor de físicas — instanciar/add_child ahí
## revienta con "Can't change this state while flushing queries". Se difiere
## un frame con call_deferred para que corra fuera de ese callback.
func _on_critical_hit_landed(_hurtbox: Hurtbox) -> void:
	if not RuneAltarManager.has_crit_trigger("active"):
		return
	var composed := RuneAltarManager.get_composed_attack_data(base_attack_data, "active")
	call_deferred("_cast_trigger_spell", composed, _dash_direction)

## Hechizo casteado por una Runa de Desencadenante (Dash/Crítico), nunca por
## input manual: siempre un nodo suelto (SpellBurst o Projectile), para no
## interferir con la máquina de estados de ataque/dash del Player.
func _cast_trigger_spell(attack_data: AttackData, direction: Vector2) -> void:
	if attack_data.is_projectile:
		_fire_projectile_spell(attack_data, direction)
	else:
		var burst: SpellBurst = SPELL_BURST_SCENE.instantiate()
		burst.attack_data = attack_data
		burst.source_override = self
		get_parent().add_child(burst)
		burst.global_position = global_position + direction * attack_range_offset

func _fire_projectile_spell(attack_data: AttackData, direction: Vector2) -> void:
	var projectile: Projectile = SPECTRAL_PROJECTILE_SCENE.instantiate()
	projectile.attack_data = attack_data
	projectile.direction = direction
	projectile.source_override = self
	get_parent().add_child(projectile)
	projectile.global_position = global_position + direction * attack_range_offset

func _update_animation(is_moving: bool) -> void:
	animated_sprite.flip_h = _dash_direction.x < 0
	var anim_name := ("walk_" if is_moving else "idle_") + _facing_from_direction(_dash_direction)
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func _facing_from_direction(dir: Vector2) -> String:
	if absf(dir.x) > absf(dir.y):
		return "side"
	elif dir.y > 0.0:
		return "front"
	else:
		return "back"
