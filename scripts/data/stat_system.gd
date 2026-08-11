extends Node
class_name StatSystem
## Gestor de atributos y stats derivados (GDD sección 4.2).

signal stats_recalculated

@export_group("Atributos Base")
@export var strength: int = 10
@export var agility: int = 10
@export var intelligence: int = 10
@export var vigor: int = 10
@export var runic_affinity: int = 10

var max_health: float
var physical_damage: float
var magic_damage: float
var crit_chance: float
var crit_multiplier: float
var attack_speed_mult: float
var move_speed_mult: float
var cooldown_reduction: float

func _ready() -> void:
	recalculate_stats()

func recalculate_stats() -> void:
	max_health = 100.0 + (vigor * 15.0)
	physical_damage = 10.0 + (strength * 2.0)
	magic_damage = intelligence * 2.5
	crit_chance = 5.0 + (agility * 0.25)
	crit_multiplier = 1.5  # sin stat que lo escale todavía (GDD 4.2 solo documenta crit_chance por agilidad)
	attack_speed_mult = 1.0 + (agility * 0.003)
	move_speed_mult = 1.0 + (agility * 0.0015)
	cooldown_reduction = clamp(runic_affinity * 0.0035, 0.0, 0.40)

	stats_recalculated.emit()
