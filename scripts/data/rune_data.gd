extends Resource
class_name RuneData
## Pieza de Soul-Crafting (GDD 3.4 / docs/REAPER_DIRECTION_ANALYSIS.md).
## Una runa sola no hace nada: RuneSpellBuilder combina 1-3 de estas en un
## AttackData temporal, que Hitbox/Hurtbox ya saben usar sin cambios.

enum RuneCategory { SHAPE, MODIFIER, TRIGGER }

@export var rune_name: String = ""
@export_multiline var description: String = ""
@export var category: RuneCategory = RuneCategory.SHAPE

## Runas de Forma (SHAPE): se combinan sobre el AttackData base.
@export var damage_multiplier_delta: float = 0.0
@export var knockback_delta: float = 0.0
@export var hitbox_radius_multiplier: float = 1.0

## Runas de Modificador (MODIFIER).
@export var lifesteal_percent: float = 0.0
@export var applies_dot: bool = false

## Runas de Desencadenante (TRIGGER) — todavía no disparan nada automático
## (eso es del Altar de Almas, Hito 8); por ahora son metadata pura.
