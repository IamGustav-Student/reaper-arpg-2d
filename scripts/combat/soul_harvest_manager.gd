extends Node
## Autoload: SoulHarvestManager (GDD sección 3.3) — medidor de almas y Modo Furia Rúnica.
## Sin class_name a propósito: como autoload ya es accesible globalmente como
## "SoulHarvestManager"; declarar también class_name colisiona con ese nombre.

signal soul_meter_changed(current: float, max_value: float)
signal rune_fury_activated

@export var soul_meter_max: float = 100.0
var soul_meter: float = 0.0

func collect_orb(essence_amount: float) -> void:
	soul_meter = clamp(soul_meter + essence_amount, 0.0, soul_meter_max)
	soul_meter_changed.emit(soul_meter, soul_meter_max)
	if soul_meter >= soul_meter_max:
		rune_fury_activated.emit()

## Consume cargas de alma para ejecutar una Definitiva. Devuelve false si no alcanza.
func consume_charge(cost: float) -> bool:
	if soul_meter < cost:
		return false
	soul_meter -= cost
	soul_meter_changed.emit(soul_meter, soul_meter_max)
	return true
