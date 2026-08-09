extends Area2D
class_name Hitbox
## Zona de daño activa solo durante la ventana de frames de un ataque
## (GDD sección 3.1). Alternar con set_active() desde un Call Method Track
## del AnimationPlayer en active_frame_start / active_frame_end.
##
## monitoring queda SIEMPRE en true: solo alternar monitoring true/false en el
## mismo frame en que se reposiciona el hitbox no garantiza que area_entered
## dispare para solapamientos que ya existían en ese instante (el physics
## server todavía no sincronizó el nuevo estado). En cambio, mientras
## _active es true, se revisan las áreas solapadas en cada _physics_process.

signal hit_landed(hurtbox: Hurtbox)

const MASK_HURTBOX := 1 << 2   # detecta la capa "Hurtbox" (ver project.godot [layer_names])

@export var attack_data: AttackData

var _active: bool = false
var _hit_targets_this_swing: Array[Hurtbox] = []

func _ready() -> void:
	monitoring = true
	collision_mask = MASK_HURTBOX
	area_entered.connect(_on_area_entered)

func set_active(value: bool) -> void:
	_active = value
	if value:
		_hit_targets_this_swing.clear()

func _physics_process(_delta: float) -> void:
	if not _active:
		return
	for area in get_overlapping_areas():
		_try_hit(area)

func _on_area_entered(area: Area2D) -> void:
	if _active:
		_try_hit(area)

func _try_hit(area: Area2D) -> void:
	if not (area is Hurtbox):
		return
	if area.get_owner() == get_owner():
		return  # no golpearse a uno mismo (el propio Hurtbox también es capa "Hurtbox")
	if _hit_targets_this_swing.has(area):
		return  # evita múltiples golpes del mismo swing sobre el mismo objetivo

	_hit_targets_this_swing.append(area)
	area.receive_hit(attack_data, get_owner())
	hit_landed.emit(area)
