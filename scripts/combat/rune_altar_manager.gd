extends Node
## Autoload: RuneAltarManager (GDD 3.4 / Hito 8) — desbloqueo de Runas
## gastando Esencia de Alma (SoulHarvestManager.consume_charge, la misma
## mecánica ya usada para las Definitivas) y equipamiento en los Slots que
## el Skill Tree desbloquea (Tier 1 = Activa, Tier 3 = Movilidad).
##
## Sin class_name a propósito, mismo motivo que SoulHarvestManager/
## SkillTreeManager: colisionaría con el nombre del autoload.

signal rune_unlocked(rune: RuneData)
signal loadout_changed

const UNLOCK_COST := 30.0
const MAX_RUNES_PER_SLOT := 3

## Runas de Desencadenante (Hito 13): identidad fija para poder preguntar
## "¿este slot dispara automático con X evento?" sin comparar por nombre.
const TRIGGER_ON_DODGE: RuneData = preload("res://resources/runes/rune_on_dodge.tres")
const TRIGGER_ON_CRIT: RuneData = preload("res://resources/runes/rune_on_crit.tres")

var unlocked_runes: Array[RuneData] = []
var active_slot_runes: Array[RuneData] = []
var mobility_slot_runes: Array[RuneData] = []

func is_unlocked(rune: RuneData) -> bool:
	return unlocked_runes.has(rune)

func can_unlock(rune: RuneData) -> bool:
	return not is_unlocked(rune) and SoulHarvestManager.soul_meter >= UNLOCK_COST

func unlock(rune: RuneData) -> bool:
	if not can_unlock(rune):
		return false
	if not SoulHarvestManager.consume_charge(UNLOCK_COST):
		return false
	unlocked_runes.append(rune)
	rune_unlocked.emit(rune)
	return true

func _slot_array(slot: String) -> Array:
	return active_slot_runes if slot == "active" else mobility_slot_runes

## Alterna la runa dentro/fuera del slot (equipar si no está, quitar si ya
## está). Devuelve false si la runa no está desbloqueada o el slot ya tiene
## el máximo de runas y se intenta agregar una nueva.
func equip(rune: RuneData, slot: String) -> bool:
	if not is_unlocked(rune):
		return false

	var target := _slot_array(slot)
	if target.has(rune):
		target.erase(rune)
	else:
		if target.size() >= MAX_RUNES_PER_SLOT:
			return false
		target.append(rune)

	loadout_changed.emit()
	return true

func is_equipped(rune: RuneData, slot: String) -> bool:
	return _slot_array(slot).has(rune)

## true si el jugador crafteó ese slot para dispararse solo con Dash/Crítico
## (Hito 13). Player los consulta para saber si debe auto-castear el slot.
func has_dodge_trigger(slot: String) -> bool:
	return is_equipped(TRIGGER_ON_DODGE, slot)

func has_crit_trigger(slot: String) -> bool:
	return is_equipped(TRIGGER_ON_CRIT, slot)

## Compone el AttackData real para lo que el jugador tenga craftado en un
## slot. Si el slot está vacío, devuelve el `base` sin cambios (compatible
## con no tener ninguna runa equipada todavía).
func get_composed_attack_data(base: AttackData, slot: String) -> AttackData:
	var runes := _slot_array(slot)
	if runes.is_empty():
		return base
	return RuneSpellBuilder.compose(base, runes)
