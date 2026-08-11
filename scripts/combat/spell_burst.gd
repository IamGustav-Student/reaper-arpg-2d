extends Hitbox
class_name SpellBurst
## Ráfaga de daño puntual sin movimiento, para hechizos disparados por
## Runas de Desencadenante (Dash / Crítico, Hito 13). No reusa el Hitbox
## propio del Player para no pisar su máquina de estados de ataque/dash —
## se instancia suelta, se activa un instante y se destruye sola (mismo
## patrón que Projectile/TelegraphArea).

@export var duration: float = 0.15

func _ready() -> void:
	super._ready()
	set_active(true)
	get_tree().create_timer(duration).timeout.connect(queue_free)
