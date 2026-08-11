extends Node2D
## Genera y descarga bosque procedimentalmente en "chunks" alrededor del
## jugador para que el mundo nunca termine en un espacio vacío. El chunk
## (0,0) es la ruina hecha a mano que ya existe en la escena — nunca se
## genera ni se descarga.
##
## Cada chunk se siembra con hash(coord) como semilla, así que si el
## jugador se aleja y vuelve, el chunk se regenera con el MISMO layout
## (determinístico) — pero los enemigos vuelven a aparecer aunque ya los
## hayas matado, ya que no se persiste el estado entre descargas. Aceptable
## para esta etapa; una versión futura podría llevar registro de qué
## chunks/enemigos ya se "limpiaron".

const CHUNK_SIZE := 1200.0
const LOAD_RADIUS := 1  # grilla de (2*LOAD_RADIUS+1)^2 chunks cargados

const TREE_TEXTURES := [
	"res://art/environment/tiny_rpg_forest/sliced-objects/tree-orange.png",
	"res://art/environment/tiny_rpg_forest/sliced-objects/tree-pink.png",
	"res://art/environment/tiny_rpg_forest/sliced-objects/tree-dried.png",
]
const BUSH_TEXTURES := [
	"res://art/environment/tiny_rpg_forest/sliced-objects/bush.png",
	"res://art/environment/tiny_rpg_forest/sliced-objects/bush-tall.png",
]
const ROCK_TEXTURE := "res://art/environment/tiny_rpg_forest/sliced-objects/rock.png"
const FLOOR_TEXTURE := "res://art/environment/tiny_rpg_forest/ruins/floor_dirt.png"

## Tiers de peligro por distancia (Chebyshev) al chunk (0,0) — la ruina.
## Ver docs/ENEMY_AND_BOSS_PROGRESSION_PLAN.md sección 2.
const TIER_STAT_MULTIPLIER := [1.0, 1.0, 1.5, 2.2, 3.0]
const TIER_ELITE_CHANCE := [0.0, 0.0, 0.15, 0.30, 0.45]

const BOSS_MIN_DISTANCE := 5
const BOSS_CHUNK_MODULO := 7  # 1 de cada 7 chunks elegibles (distancia >= 5) es un Boss Chunk

var _enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/mole.tscn"),
	preload("res://scenes/enemies/treant.tscn"),
	preload("res://scenes/enemies/ranged_enemy.tscn"),
]
var _boss_scene: PackedScene = preload("res://scenes/enemies/boss_treant.tscn")

var _player: Node2D
var _loaded_chunks: Dictionary = {}  # Vector2i -> Node2D
var _check_timer: float = 0.0

func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		return

	_check_timer -= delta
	if _check_timer > 0.0:
		return
	_check_timer = 0.5

	_update_chunks(_world_to_chunk(_player.global_position))

func _update_chunks(current_chunk: Vector2i) -> void:
	var needed: Dictionary = {}
	for x in range(current_chunk.x - LOAD_RADIUS, current_chunk.x + LOAD_RADIUS + 1):
		for y in range(current_chunk.y - LOAD_RADIUS, current_chunk.y + LOAD_RADIUS + 1):
			needed[Vector2i(x, y)] = true

	for coord in needed.keys():
		if coord == Vector2i.ZERO:
			continue  # la sala inicial ya existe hecha a mano
		if not _loaded_chunks.has(coord):
			_loaded_chunks[coord] = _generate_forest_chunk(coord)

	for coord in _loaded_chunks.keys().duplicate():
		if not needed.has(coord):
			_loaded_chunks[coord].queue_free()
			_loaded_chunks.erase(coord)

func _world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / CHUNK_SIZE), floori(world_pos.y / CHUNK_SIZE))

func _danger_tier(coord: Vector2i) -> int:
	var distance := maxi(absi(coord.x), absi(coord.y))
	if distance <= 1:
		return 0
	elif distance <= 3:
		return 1
	elif distance <= 6:
		return 2
	elif distance <= 10:
		return 3
	else:
		return 4

## Determinístico (misma semilla que el resto del chunk): reproducible, no
## aleatorio puro. Ver docs/ENEMY_AND_BOSS_PROGRESSION_PLAN.md sección 3.
func _is_boss_chunk(coord: Vector2i) -> bool:
	var distance := maxi(absi(coord.x), absi(coord.y))
	if distance < BOSS_MIN_DISTANCE:
		return false
	return absi(hash(coord)) % BOSS_CHUNK_MODULO == 0

func _generate_forest_chunk(coord: Vector2i) -> Node2D:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(coord)
	var tier := _danger_tier(coord)

	var chunk := Node2D.new()
	chunk.name = "Chunk_%d_%d" % [coord.x, coord.y]
	chunk.position = Vector2(coord) * CHUNK_SIZE
	chunk.y_sort_enabled = true
	add_child(chunk)

	var half := CHUNK_SIZE / 2.0

	_spawn_floor(chunk, half)

	for i in rng.randi_range(4, 7):
		var local_pos := Vector2(rng.randf_range(-half, half), rng.randf_range(-half, half))
		_spawn_tree(chunk, TREE_TEXTURES[rng.randi_range(0, TREE_TEXTURES.size() - 1)], local_pos, rng.randf_range(1.6, 2.2))

	for i in rng.randi_range(3, 6):
		var local_pos := Vector2(rng.randf_range(-half, half), rng.randf_range(-half, half))
		if rng.randf() < 0.5:
			_spawn_decoration(chunk, BUSH_TEXTURES[rng.randi_range(0, BUSH_TEXTURES.size() - 1)], local_pos)
		else:
			_spawn_rock(chunk, local_pos)

	if _is_boss_chunk(coord):
		_spawn_boss(chunk)
	else:
		for i in rng.randi_range(1, 3):
			var local_pos := Vector2(rng.randf_range(-half, half), rng.randf_range(-half, half))
			var enemy_scene: PackedScene = _enemy_scenes[rng.randi_range(0, _enemy_scenes.size() - 1)]
			var enemy: Enemy = enemy_scene.instantiate()
			enemy.position = local_pos
			enemy.power_multiplier = TIER_STAT_MULTIPLIER[tier]
			enemy.is_elite = rng.randf() < TIER_ELITE_CHANCE[tier]
			chunk.add_child(enemy)

	return chunk

func _spawn_boss(chunk: Node2D) -> void:
	var boss: Node2D = _boss_scene.instantiate()
	boss.position = Vector2.ZERO
	chunk.add_child(boss)

func _spawn_floor(chunk: Node2D, half: float) -> void:
	var floor_rect := TextureRect.new()
	floor_rect.z_index = -10
	floor_rect.texture = load(FLOOR_TEXTURE)
	floor_rect.texture_filter = 1
	floor_rect.stretch_mode = TextureRect.STRETCH_TILE
	floor_rect.offset_left = -half
	floor_rect.offset_top = -half
	floor_rect.offset_right = half
	floor_rect.offset_bottom = half
	chunk.add_child(floor_rect)

func _spawn_tree(parent: Node2D, texture_path: String, local_pos: Vector2, scale_factor: float) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.position = local_pos
	body.scale = Vector2(scale_factor, scale_factor)
	parent.add_child(body)

	var texture: Texture2D = load(texture_path)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.offset = Vector2(0, -texture.get_height() / 2.0)
	sprite.texture_filter = 1
	body.add_child(sprite)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	body.add_child(shape)

func _spawn_decoration(parent: Node2D, texture_path: String, local_pos: Vector2) -> void:
	var texture: Texture2D = load(texture_path)
	var node := Node2D.new()
	node.position = local_pos
	node.scale = Vector2(2.0, 2.0)
	parent.add_child(node)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.offset = Vector2(0, -texture.get_height() / 2.0)
	sprite.texture_filter = 1
	node.add_child(sprite)

func _spawn_rock(parent: Node2D, local_pos: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.position = local_pos
	body.scale = Vector2(2.0, 2.0)
	parent.add_child(body)

	var sprite := Sprite2D.new()
	sprite.texture = load(ROCK_TEXTURE)
	sprite.offset = Vector2(0, -14)
	sprite.texture_filter = 1
	body.add_child(sprite)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	body.add_child(shape)
