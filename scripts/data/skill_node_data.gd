extends Resource
class_name SkillNodeData
## Nodo de árbol de habilidades (GDD sección 5). Instanciar como .tres por nodo/tier.

enum NodeType { ACTIVE, PASSIVE, KEYSTONE }

@export var skill_name: String = ""
@export_multiline var description: String = ""
@export var node_type: NodeType = NodeType.ACTIVE
@export var max_level: int = 1
@export var mana_cost: float = 0.0
@export var cooldown: float = 0.0
@export var required_points_in_branch: int = 0
@export var icon: Texture2D
