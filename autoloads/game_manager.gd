extends Node
## Autoload: GameManager
## Estado global de partida (nivel, pausa, progresión de Fisuras Rúnicas).

signal game_paused(is_paused: bool)

var current_player_level: int = 1
var current_xp_total: float = 0.0

func pause_game() -> void:
	get_tree().paused = true
	game_paused.emit(true)

func resume_game() -> void:
	get_tree().paused = false
	game_paused.emit(false)

## XP_Requerida(L) = 100 * L^2.15 + 150 * L — fórmula GDD sección 4.1
func xp_required_for_level(level: int) -> float:
	return 100.0 * pow(level, 2.15) + 150.0 * level
