extends Projectile
class_name SpectralProjectile
## Visual del Proyectil Espectral (Runa de Forma, Soul-Crafting, Hito 13):
## mismo comportamiento que Projectile, dibujado con primitivas en vez de
## sprite — mismo criterio que SoulOrb._draw() (sin arte nuevo).

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.6, 0.25, 0.9, 0.85))
	draw_circle(Vector2.ZERO, 5.0, Color(0.95, 0.85, 1.0, 1.0))
