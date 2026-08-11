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
## Devuelve true si el golpe fue crítico (Hitbox lo usa para disparar la
## Runa de Desencadenante "Al Asestar Crítico", GDD 3.4 / Hito 13).
func receive_hit(attack_data: AttackData, source: Node) -> bool:
	if health_system == null:
		return false

	var attacker_physical_damage := 10.0  # fallback si el atacante no tiene StatSystem
	var is_crit := false
	if source and source.has_node("StatSystem"):
		var attacker_stats: StatSystem = source.get_node("StatSystem")
		attacker_physical_damage = attacker_stats.physical_damage
		is_crit = randf() * 100.0 < attacker_stats.crit_chance
		if is_crit:
			attacker_physical_damage *= attacker_stats.crit_multiplier
	elif source is Enemy:
		attacker_physical_damage *= source.power_multiplier

	var damage := attack_data.base_damage_multiplier * attacker_physical_damage
	health_system.take_damage(damage)
	damage_received.emit(damage, source)

	# Runa de Modificador "Sed de Sangre" (Soul-Crafting, GDD 3.4): cura al
	# atacante un % del daño infligido.
	if attack_data.lifesteal_percent > 0.0 and source and source.has_node("HealthSystem"):
		var attacker_health: HealthSystem = source.get_node("HealthSystem")
		attacker_health.heal(damage * attack_data.lifesteal_percent)

	# Runa de Modificador "Ceniza de Sombra": daño adicional por tiempo.
	if attack_data.dot_damage_per_tick > 0.0 and attack_data.dot_tick_count > 0:
		_apply_dot(attack_data.dot_damage_per_tick, attack_data.dot_tick_count, attack_data.dot_tick_interval)

	return is_crit

func _apply_dot(damage_per_tick: float, tick_count: int, tick_interval: float) -> void:
	for i in tick_count:
		await get_tree().create_timer(tick_interval).timeout
		if health_system and is_instance_valid(health_system) and health_system.current_health > 0.0:
			health_system.take_damage(damage_per_tick)
