extends CanvasLayer
## UI del Altar de Almas (GDD 3.4, Hito 8) — desbloquear Runas gastando
## Esencia de Alma y equiparlas en el Slot Activo o de Movilidad. Se abre
## y cierra con la acción de input "toggle_altar".

const RUNES: Array[RuneData] = [
	preload("res://resources/runes/rune_slash_spin.tres"),
	preload("res://resources/runes/rune_spectral_scythe.tres"),
	preload("res://resources/runes/rune_nova.tres"),
	preload("res://resources/runes/rune_bloodthirst.tres"),
	preload("res://resources/runes/rune_ash.tres"),
	preload("res://resources/runes/rune_on_dodge.tres"),
	preload("res://resources/runes/rune_on_crit.tres"),
]

const CATEGORY_TAGS := ["Forma", "Modificador", "Trigger"]

@onready var essence_label: Label = $Panel/EssenceLabel
@onready var slot_active_button: Button = $Panel/SlotActiveButton
@onready var slot_mobility_button: Button = $Panel/SlotMobilityButton
@onready var _unlock_buttons: Array[Button] = []
@onready var _equip_buttons: Array[Button] = []

var _selected_slot: String = "active"

func _ready() -> void:
	visible = false

	slot_active_button.pressed.connect(_select_slot.bind("active"))
	slot_mobility_button.pressed.connect(_select_slot.bind("mobility"))

	for i in range(RUNES.size()):
		var unlock_btn: Button = get_node("Panel/UnlockButton%d" % (i + 1))
		var equip_btn: Button = get_node("Panel/EquipButton%d" % (i + 1))
		unlock_btn.pressed.connect(_on_unlock_pressed.bind(i))
		equip_btn.pressed.connect(_on_equip_pressed.bind(i))
		_unlock_buttons.append(unlock_btn)
		_equip_buttons.append(equip_btn)

	SoulHarvestManager.soul_meter_changed.connect(_on_state_changed)
	RuneAltarManager.rune_unlocked.connect(_on_state_changed)
	RuneAltarManager.loadout_changed.connect(_on_state_changed)

	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_altar"):
		visible = not visible
		if visible:
			_refresh()

func _select_slot(slot: String) -> void:
	_selected_slot = slot
	_refresh()

func _on_unlock_pressed(index: int) -> void:
	RuneAltarManager.unlock(RUNES[index])

func _on_equip_pressed(index: int) -> void:
	RuneAltarManager.equip(RUNES[index], _selected_slot)

func _on_state_changed(_a = null, _b = null) -> void:
	_refresh()

func _refresh() -> void:
	essence_label.text = "Esencia de Alma: %d" % int(SoulHarvestManager.soul_meter)
	slot_active_button.text = "Slot Activo" + (" [editando]" if _selected_slot == "active" else "")
	slot_mobility_button.text = "Slot Movilidad" + (" [editando]" if _selected_slot == "mobility" else "")

	for i in range(RUNES.size()):
		var rune := RUNES[i]
		var unlocked := RuneAltarManager.is_unlocked(rune)

		var unlock_btn := _unlock_buttons[i]
		unlock_btn.text = "%s [%s]\n%s%s" % [
			rune.rune_name, CATEGORY_TAGS[rune.category], rune.description,
			"\n(Desbloqueada)" if unlocked else "\n(Desbloquear — %d Esencia)" % RuneAltarManager.UNLOCK_COST
		]
		unlock_btn.disabled = unlocked or not RuneAltarManager.can_unlock(rune)

		var equip_btn := _equip_buttons[i]
		var equipped := RuneAltarManager.is_equipped(rune, _selected_slot)
		var slot_runes: Array = RuneAltarManager.active_slot_runes if _selected_slot == "active" else RuneAltarManager.mobility_slot_runes
		var slot_full := slot_runes.size() >= RuneAltarManager.MAX_RUNES_PER_SLOT
		equip_btn.text = "Quitar" if equipped else "Equipar"
		equip_btn.disabled = not unlocked or (not equipped and slot_full)
