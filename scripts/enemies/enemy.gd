extends CharacterBody2D
class_name Enemy
## Comportamiento común de enemigos: al morir (HealthSystem.died), suelta un
## Orbe de Alma y se elimina. La IA/movimiento se agrega en un pase posterior.

@export var soul_orb_scene: PackedScene
@export var soul_essence_drop: float = 15.0

@onready var health_system: HealthSystem = $HealthSystem

func _ready() -> void:
	health_system.died.connect(_on_died)

func _on_died() -> void:
	if soul_orb_scene:
		var orb: Node2D = soul_orb_scene.instantiate()
		orb.global_position = global_position
		orb.essence_amount = soul_essence_drop
		get_parent().add_child(orb)
	queue_free()
