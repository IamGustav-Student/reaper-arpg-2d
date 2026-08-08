extends Area2D
class_name Hurtbox
## Zona de recepción de daño (GDD sección 3.1). collision_layer alterna entre
## "Hurtbox" e "Invulnerable" durante los i-frames del Dash.

signal damage_received(amount: float, source: Node)

const LAYER_HURTBOX := 1 << 2   # capa "Hurtbox" (bit 3, ver project.godot [layer_names])
const LAYER_INVULNERABLE := 1 << 3   # capa "Invulnerable" (bit 4)

@export var health_system: HealthSystem

func _ready() -> void:
	collision_layer = LAYER_HURTBOX
	collision_mask = 0

func set_invulnerable(value: bool) -> void:
	collision_layer = LAYER_INVULNERABLE if value else LAYER_HURTBOX

## Llamado por Hitbox.gd al detectar solapamiento. El cálculo real de daño debe
## combinar StatSystem del atacante + AttackData; aquí se deja un placeholder simple.
func receive_hit(attack_data: AttackData, source: Node) -> void:
	if health_system == null:
		return
	var damage := attack_data.base_damage_multiplier * 10.0
	health_system.take_damage(damage)
	damage_received.emit(damage, source)
