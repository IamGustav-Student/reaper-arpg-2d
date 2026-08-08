extends Resource
class_name ItemData
## Item de loot (GDD sección 4.3). Instanciar como .tres por objeto/plantilla.

enum Rarity { COMMON, MAGIC, RARE, EPIC, LEGENDARY }

@export var item_name: String = ""
@export var rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D
@export var rune_slots: int = 0
@export var prefixes: Array[String] = []
@export var suffixes: Array[String] = []
