extends Resource
class_name AttackData
## Equivalente al ScriptableObject `AttackDataSO` de Unity (GDD sección 3.1).
## Se instancia como recurso .tres: click derecho en resources/attacks/ > Nuevo Recurso > AttackData.

enum ElementType { PHYSICAL, FIRE, FROST, SHADOW }

@export var attack_name: String = ""
@export var base_damage_multiplier: float = 1.0
@export var knockback_force: float = 5.0
@export var stagger_duration: float = 0.2
@export var active_frame_start: int = 2
@export var active_frame_end: int = 4
@export var element_type: ElementType = ElementType.PHYSICAL
@export var hit_vfx_scene: PackedScene
@export var hit_sfx: AudioStream
