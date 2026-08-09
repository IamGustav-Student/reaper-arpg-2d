extends Node2D
class_name SoulOrb
## Orbe de Esencia de Alma (GDD sección 3.3). Vuela hacia el jugador dentro del
## radio de atracción y se recolecta al contacto, sumando al SoulHarvestManager.

@export var essence_amount: float = 10.0
@export var attraction_radius: float = 120.0
@export var attraction_speed: float = 350.0
@export var pickup_distance: float = 10.0

var _target: Node2D

func _ready() -> void:
	_target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _target == null:
		return

	var to_target := _target.global_position - global_position
	var distance := to_target.length()

	if distance <= pickup_distance:
		SoulHarvestManager.collect_orb(essence_amount)
		queue_free()
		return

	if distance <= attraction_radius:
		global_position += to_target.normalized() * attraction_speed * delta

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color(0.55, 0.2, 0.85, 0.9))
	draw_circle(Vector2.ZERO, 3.0, Color(0.9, 0.8, 1.0, 1.0))
