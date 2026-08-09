extends Node
## Autoload: SkillTreeManager (GDD sección 5) — puntos de habilidad y nivel
## invertido por nodo. Sin class_name a propósito, mismo motivo que
## SoulHarvestManager: colisionaría con el nombre del autoload.
##
## available_points arranca en 5 como valor de prueba: todavía no hay un
## sistema de experiencia/subida de nivel conectado (GameManager.xp_required_
## for_level existe pero nada otorga XP aún), así que no hay una fuente real
## de puntos de habilidad todavía — ver GDD Hito 6 / roadmap.

signal points_changed(available: int)
signal node_leveled(node: SkillNodeData, new_level: int)

@export var available_points: int = 5

var node_levels: Dictionary = {}  # SkillNodeData -> int

func get_node_level(node: SkillNodeData) -> int:
	return node_levels.get(node, 0)

## Suma los niveles invertidos en todos los nodos de una rama (para
## comparar contra required_points_in_branch de cada nodo).
func get_branch_points_spent(branch_nodes: Array) -> int:
	var total := 0
	for node in branch_nodes:
		total += get_node_level(node)
	return total

func can_invest(node: SkillNodeData, branch_nodes: Array) -> bool:
	if available_points <= 0:
		return false
	if get_node_level(node) >= node.max_level:
		return false
	return get_branch_points_spent(branch_nodes) >= node.required_points_in_branch

func invest(node: SkillNodeData, branch_nodes: Array) -> bool:
	if not can_invest(node, branch_nodes):
		return false

	available_points -= 1
	var new_level: int = get_node_level(node) + 1
	node_levels[node] = new_level

	points_changed.emit(available_points)
	node_leveled.emit(node, new_level)
	return true
