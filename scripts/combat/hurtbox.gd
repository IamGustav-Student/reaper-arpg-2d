extends Area2D
class_name Hurtbox
## Zona de recepción de daño (GDD sección 3.1). collision_layer alterna entre
## "Hurtbox" e "Invulnerable" durante los i-frames del Dash.
##
## health_system se resuelve por convención de estructura (nodo hermano
## "HealthSystem"), no por @export: un @export tipado como HealthSystem
## asignado a mano en un .tscn como NodePath(...) NO se resuelve a una
## referencia real de nodo (queda null) — solo funciona si se arrastra desde
## el inspector del editor.

signal damage_received(amount: float, source: Node)

const LAYER_HURTBOX := 1 << 2   # capa "Hurtbox" (ver project.godot [layer_names])
const LAYER_INVULNERABLE := 1 << 3   # capa "Invulnerable"

@onready var health_system: HealthSystem = get_node("../HealthSystem")

func _ready() -> void:
	collision_layer = LAYER_HURTBOX
	collision_mask = 0

func set_invulnerable(value: bool) -> void:
	collision_layer = LAYER_INVULNERABLE if value else LAYER_HURTBOX

## Llamado por Hitbox.gd al detectar solapamiento. Combina el daño físico del
## StatSystem del atacante (si tiene uno) con el multiplicador del ataque.
func receive_hit(attack_data: AttackData, source: Node) -> void:
	if health_system == null:
		return

	var attacker_physical_damage := 10.0  # fallback si el atacante no tiene StatSystem
	if source and source.has_node("StatSystem"):
		var attacker_stats: StatSystem = source.get_node("StatSystem")
		attacker_physical_damage = attacker_stats.physical_damage
	elif source is Enemy:
		attacker_physical_damage *= source.power_multiplier

	var damage := attack_data.base_damage_multiplier * attacker_physical_damage
	health_system.take_damage(damage)
	damage_received.emit(damage, source)
