extends CanvasLayer
## HUD mínimo: barra de Vida del jugador + Medidor de Almas (GDD sección 3.3 / 8).

const HEALTH_BAR_WIDTH := 220.0
const SOUL_BAR_WIDTH := 220.0

@onready var health_fill: ColorRect = $HealthBarFill
@onready var soul_fill: ColorRect = $SoulBarFill

func _ready() -> void:
	SoulHarvestManager.soul_meter_changed.connect(_on_soul_changed)
	_on_soul_changed(SoulHarvestManager.soul_meter, SoulHarvestManager.soul_meter_max)

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var health_system: HealthSystem = player.get_node("HealthSystem")
	health_system.health_changed.connect(_on_health_changed)
	_on_health_changed(health_system.current_health, health_system.max_health)

func _on_health_changed(current: float, max_value: float) -> void:
	health_fill.size.x = HEALTH_BAR_WIDTH * clamp(current / max_value, 0.0, 1.0)

func _on_soul_changed(current: float, max_value: float) -> void:
	soul_fill.size.x = SOUL_BAR_WIDTH * clamp(current / max_value, 0.0, 1.0)
