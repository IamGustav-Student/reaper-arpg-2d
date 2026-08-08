extends Node2D
## Placeholder visual temporal (sin sprite final) — ver art/ASSETS_SOURCES.md.
## Dibuja un círculo simple para poder confirmar movimiento/animación antes de tener arte.

@export var color: Color = Color(0.3, 0.8, 0.4)
@export var radius: float = 24.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color.darkened(0.4), 2.0)
	# Indicador de dirección (rotar este nodo para apuntar hacia donde mira el personaje)
	draw_line(Vector2.ZERO, Vector2(radius * 1.3, 0.0), Color.WHITE, 3.0)
