extends Node2D
class_name TelegraphArea
## Aviso visual antes de un ataque de área (GDD 8.1 "Telegrafiado Rojo").
## Puramente visual + un timer — el que la instancia decide qué hacer
## cuando termina (activar un Hitbox grande en su posición, por ejemplo).

signal telegraph_finished

@export var warning_duration: float = 1.5
@export var radius: float = 90.0

func _ready() -> void:
	var timer := get_tree().create_timer(warning_duration)
	await timer.timeout
	telegraph_finished.emit()
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.15, 0.15, 0.35))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.2, 0.2, 0.8), 3.0)
