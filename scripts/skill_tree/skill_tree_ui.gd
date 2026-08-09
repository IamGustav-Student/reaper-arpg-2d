extends CanvasLayer
## UI del árbol de habilidades — Cosechador, Rama A: Sombras (GDD 5.1).
## Se abre/cierra con la acción de input "toggle_skill_tree".

const BRANCH_NODES: Array[SkillNodeData] = [
	preload("res://resources/skills/shadow_dance.tres"),
	preload("res://resources/skills/voracious_blades.tres"),
	preload("res://resources/skills/spectral_step.tres"),
	preload("res://resources/skills/dark_seduction.tres"),
	preload("res://resources/skills/unleashed_soul_frenzy.tres"),
]

@onready var points_label: Label = $Panel/PointsLabel
@onready var _node_buttons: Array[Button] = [
	$Panel/NodeButton1, $Panel/NodeButton2, $Panel/NodeButton3,
	$Panel/NodeButton4, $Panel/NodeButton5,
]

func _ready() -> void:
	visible = false
	for i in range(_node_buttons.size()):
		_node_buttons[i].pressed.connect(_on_node_pressed.bind(i))
	SkillTreeManager.points_changed.connect(_on_points_changed)
	SkillTreeManager.node_leveled.connect(_on_node_leveled)
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_skill_tree"):
		visible = not visible
		if visible:
			_refresh()

func _on_node_pressed(index: int) -> void:
	SkillTreeManager.invest(BRANCH_NODES[index], BRANCH_NODES)

func _on_points_changed(_available: int) -> void:
	_refresh()

func _on_node_leveled(_node: SkillNodeData, _level: int) -> void:
	_refresh()

func _refresh() -> void:
	points_label.text = "Puntos disponibles: %d" % SkillTreeManager.available_points
	var branch_total := SkillTreeManager.get_branch_points_spent(BRANCH_NODES)

	for i in range(BRANCH_NODES.size()):
		var node := BRANCH_NODES[i]
		var btn := _node_buttons[i]
		var level := SkillTreeManager.get_node_level(node)
		var unlocked := branch_total >= node.required_points_in_branch
		var maxed := level >= node.max_level

		var tier_tag: String = ["Activo", "Pasivo", "Keystone"][node.node_type]
		btn.text = "%s [%s]  Nv %d/%d\nReq: %d pts en rama\n%s" % [
			node.skill_name, tier_tag, level, node.max_level,
			node.required_points_in_branch, node.description
		]
		btn.disabled = not unlocked or maxed or SkillTreeManager.available_points <= 0

		if maxed:
			btn.modulate = Color(1.0, 0.85, 0.3)
		elif unlocked:
			btn.modulate = Color(1, 1, 1)
		else:
			btn.modulate = Color(0.5, 0.5, 0.5)
