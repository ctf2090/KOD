extends Node2D
class_name TownMap

# Avoid relying on class_name registration order during headless loads.
const TilesetFactory = preload("res://scripts/town_tileset_factory.gd")

# Simple 16x16 top-down town map:
# - Generated procedurally, rendered via TileMapLayer + 16x16 atlas texture.
# - Provides walkability queries for the player controller.

enum Mode {
	MANUAL = 0,
	PROCEDURAL = 1,
}

@export var mode: Mode = Mode.MANUAL
@export var tile_size := 16
@export var map_width := 40
@export var map_height := 30
@export var ground_layer_path: NodePath
@export var buildings_layer_path: NodePath
@export var atlas_png_path := "res://assets/tiles/ground_atlas.png" # ground atlas
@export var building_atlas_png_path := "res://assets/tiles/building_atlas.png"

enum Tile {
	GRASS = 0,
	ROAD = 1,
	SIDEWALK = 2,
	BUILDING = 3,
}

var _tiles: PackedInt32Array = PackedInt32Array()
var _ground: TileMapLayer = null
var _buildings: TileMapLayer = null

func _ready() -> void:
	_ground = get_node_or_null(ground_layer_path) as TileMapLayer
	if _ground == null:
		push_warning("TownMap: ground_layer_path is not set; map won't render.")
		return

	_buildings = get_node_or_null(buildings_layer_path) as TileMapLayer

	# Ensure Ground has a TileSet so the editor can paint tiles even if this node
	# runs in-game. In manual mode we must NOT clear/overwrite painted tiles.
	if _ground.tile_set == null:
		var ts_ground: TileSet = TilesetFactory.build_ground(atlas_png_path)
		if ts_ground != null:
			_ground.tile_set = ts_ground

	if _buildings != null and _buildings.tile_set == null:
		var ts_buildings: TileSet = TilesetFactory.build_buildings(building_atlas_png_path)
		if ts_buildings != null:
			_buildings.tile_set = ts_buildings

	# Manual painting: if the layer is empty, seed it once so you can see something
	# immediately (and the player has walkable streets). After you paint and save,
	# we won't overwrite anything.
	if mode == Mode.MANUAL and _are_layers_empty():
		_generate()
		_apply_to_ground()
		return

	if mode == Mode.PROCEDURAL:
		_generate()
		_apply_to_ground()

func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_width and cell.y < map_height

func tile_at(cell: Vector2i) -> int:
	if not in_bounds(cell):
		return Tile.BUILDING
	if mode == Mode.MANUAL:
		# Buildings live on their own layer in manual mode too.
		if _buildings != null and _buildings.get_cell_source_id(cell) != -1:
			return Tile.BUILDING
		return _tile_at_manual(cell)
	return _tiles[cell.y * map_width + cell.x]

func is_walkable(cell: Vector2i) -> bool:
	if _buildings != null and _buildings.get_cell_source_id(cell) != -1:
		return false
	var t := tile_at(cell)
	return t == Tile.ROAD or t == Tile.SIDEWALK

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func cell_center(cell: Vector2i) -> Vector2:
	if _ground != null:
		# TileMapLayer handles the exact tile origin (Godot 4 uses centered coords).
		return _ground_local_to_parent_pos(_ground.map_to_local(cell))
	return cell_to_world(cell) + Vector2(tile_size * 0.5, tile_size * 0.5)

func world_to_cell(pos: Vector2) -> Vector2i:
	if _ground != null:
		return _ground.local_to_map(_parent_pos_to_ground_local(pos))
	return Vector2i(int(floor(pos.x / tile_size)), int(floor(pos.y / tile_size)))

func _ground_local_to_parent_pos(ground_local: Vector2) -> Vector2:
	var gpos := _ground.to_global(ground_local)
	var p := get_parent() as Node2D
	if p != null:
		return p.to_local(gpos)
	return gpos

func _parent_pos_to_ground_local(parent_pos: Vector2) -> Vector2:
	var p := get_parent() as Node2D
	var gpos := parent_pos
	if p != null:
		gpos = p.to_global(parent_pos)
	return _ground.to_local(gpos)

func _generate() -> void:
	_tiles = PackedInt32Array()
	_tiles.resize(map_width * map_height)

	# Base: grass everywhere.
	for i in range(_tiles.size()):
		_tiles[i] = Tile.GRASS

	# Carve roads: main vertical + main horizontal, plus 2 side streets.
	var road_half_width := 1 # 3 tiles wide total.
	var x_mid := map_width / 2
	var y_mid := map_height / 2

	_carve_road_rect(Rect2i(x_mid - road_half_width, 0, road_half_width * 2 + 1, map_height))
	_carve_road_rect(Rect2i(0, y_mid - road_half_width, map_width, road_half_width * 2 + 1))

	# Side streets.
	_carve_road_rect(Rect2i(6, 3, road_half_width * 2 + 1, map_height - 6))
	_carve_road_rect(Rect2i(map_width - 9, 3, road_half_width * 2 + 1, map_height - 6))

	# Sidewalk around roads.
	_add_sidewalks()

	# Buildings: fill blocks away from roads/sidewalks, leaving a bit of grass at edges.
	_place_building_blocks()

func _carve_road_rect(r: Rect2i) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_set_tile(Vector2i(x, y), Tile.ROAD)

func _add_sidewalks() -> void:
	for y in range(map_height):
		for x in range(map_width):
			var cell := Vector2i(x, y)
			if tile_at(cell) != Tile.GRASS:
				continue
			# Any adjacent road becomes sidewalk.
			if (
				tile_at(cell + Vector2i(1, 0)) == Tile.ROAD
				or tile_at(cell + Vector2i(-1, 0)) == Tile.ROAD
				or tile_at(cell + Vector2i(0, 1)) == Tile.ROAD
				or tile_at(cell + Vector2i(0, -1)) == Tile.ROAD
			):
				_set_tile(cell, Tile.SIDEWALK)

func _place_building_blocks() -> void:
	# Keep an outer grass border for "outskirts".
	var border := 2
	for y in range(border, map_height - border):
		for x in range(border, map_width - border):
			var cell := Vector2i(x, y)
			if tile_at(cell) == Tile.GRASS:
				# Prefer buildings near sidewalks (looks more "town").
				var near_sidewalk := (
					tile_at(cell + Vector2i(1, 0)) == Tile.SIDEWALK
					or tile_at(cell + Vector2i(-1, 0)) == Tile.SIDEWALK
					or tile_at(cell + Vector2i(0, 1)) == Tile.SIDEWALK
					or tile_at(cell + Vector2i(0, -1)) == Tile.SIDEWALK
				)
				if near_sidewalk:
					_set_tile(cell, Tile.BUILDING)

	# Punch some small parks (grass) back into building blocks.
	for y in range(5, map_height - 5, 8):
		for x in range(5, map_width - 5, 10):
			_clear_rect(Rect2i(x, y, 3, 3), Tile.GRASS)

func _clear_rect(r: Rect2i, t: int) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			_set_tile(Vector2i(x, y), t)

func _set_tile(cell: Vector2i, t: int) -> void:
	if not in_bounds(cell):
		return
	_tiles[cell.y * map_width + cell.x] = t

func _apply_to_ground() -> void:
	if _ground == null:
		return
	_ground.clear()
	if _buildings != null:
		_buildings.clear()

	# Source id is the first (and only) source we added.
	if _ground.tile_set == null:
		return
	var ground_source_id: int = _ground.tile_set.get_source_id(0)
	var buildings_source_id: int = -1
	if _buildings != null and _buildings.tile_set != null:
		buildings_source_id = _buildings.tile_set.get_source_id(0)

	for y in range(map_height):
		for x in range(map_width):
			var cell := Vector2i(x, y)
			var t := _tiles[y * map_width + x] if _tiles.size() == map_width * map_height else Tile.GRASS
			if _buildings != null and t == Tile.BUILDING and buildings_source_id != -1:
				var variant := _building_variant_for_cell(cell)
				var atlas_b: Vector2i = TilesetFactory.building_atlas_coords_for(variant)
				_buildings.set_cell(cell, buildings_source_id, atlas_b, 0)
			else:
				var ground_t := t
				if ground_t == Tile.BUILDING:
					ground_t = Tile.GRASS
				var atlas_g: Vector2i = TilesetFactory.ground_atlas_coords_for(ground_t)
				_ground.set_cell(cell, ground_source_id, atlas_g, 0)

func _tile_at_manual(cell: Vector2i) -> int:
	# Reads the painted TileMapLayer. If empty, treat as GRASS.
	if _ground == null:
		return Tile.BUILDING
	var sid := _ground.get_cell_source_id(cell)
	if sid == -1:
		return Tile.GRASS
	var atlas := _ground.get_cell_atlas_coords(cell)
	if atlas.y != 0:
		return Tile.GRASS
	if atlas.x < 0 or atlas.x > 2:
		return Tile.GRASS
	return atlas.x

func _building_variant_for_cell(cell: Vector2i) -> int:
	# Deterministic variant selection; keeps the same look between runs.
	return int(posmod(cell.x * 13 + cell.y * 7, 4))

func _are_layers_empty() -> bool:
	if _ground == null:
		return true
	var gr := _ground.get_used_rect()
	var br := Rect2i()
	if _buildings != null:
		br = _buildings.get_used_rect()
	return gr.size == Vector2i.ZERO and br.size == Vector2i.ZERO
