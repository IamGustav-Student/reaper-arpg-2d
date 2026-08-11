extends Hitbox
class_name Projectile
## Proyectil simple: un Hitbox que se mueve en línea recta y se destruye al
## primer impacto o tras `lifetime`. No es un sistema de combate paralelo —
## hereda toda la lógica de detección/daño de Hitbox, solo le suma movimiento.

@export var speed: float = 260.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	super._ready()
	set_active(true)  # un proyectil está "atacando" mientras vuela
	hit_landed.connect(func(_hurtbox): queue_free())
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	super._physics_process(delta)
