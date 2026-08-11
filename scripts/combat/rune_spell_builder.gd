extends RefCounted
class_name RuneSpellBuilder
## Compone un AttackData temporal a partir de 1-3 RuneData equipadas
## (Soul-Crafting, GDD 3.4). Sin sistema de combate paralelo: el resultado
## es un AttackData normal, duplicado en runtime (nunca muta el `base`
## compartido), que Hitbox/Hurtbox ya saben usar sin cambios.

static func compose(base: AttackData, runes: Array[RuneData]) -> AttackData:
	var result: AttackData = base.duplicate()

	for rune in runes:
		match rune.category:
			RuneData.RuneCategory.SHAPE:
				result.base_damage_multiplier += rune.damage_multiplier_delta
				result.knockback_force += rune.knockback_delta
				result.hitbox_radius_multiplier *= rune.hitbox_radius_multiplier
			RuneData.RuneCategory.MODIFIER:
				result.lifesteal_percent += rune.lifesteal_percent
				if rune.applies_dot:
					result.dot_damage_per_tick = result.base_damage_multiplier * 2.0
					result.dot_tick_count = 3
					result.dot_tick_interval = 1.0
			RuneData.RuneCategory.TRIGGER:
				pass  # no modifica el AttackData; define CUÁNDO se dispara (Hito 8)

	return result
