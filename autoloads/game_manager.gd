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

## Persistencia de mundo (Hito 9): qué enemigos/bosses de qué chunk ya se
## mataron. Vive en un autoload a propósito, no en ChunkManager — así
## sobrevive tanto a que el jugador se aleje y vuelva (el chunk se
## descarga/regenera) como a que muera y el nivel se reinicie
## (reload_current_scene() no destruye autoloads, solo la escena actual).
var _killed_enemy_indices: Dictionary = {}  # Vector2i -> Dictionary(int -> true)
var _defeated_boss_chunks: Dictionary = {}  # Vector2i -> true

func mark_enemy_killed(coord: Vector2i, index: int) -> void:
	if not _killed_enemy_indices.has(coord):
		_killed_enemy_indices[coord] = {}
	_killed_enemy_indices[coord][index] = true

func is_enemy_killed(coord: Vector2i, index: int) -> bool:
	return _killed_enemy_indices.get(coord, {}).has(index)

func mark_boss_defeated(coord: Vector2i) -> void:
	_defeated_boss_chunks[coord] = true

func is_boss_defeated(coord: Vector2i) -> bool:
	return _defeated_boss_chunks.get(coord, false)
