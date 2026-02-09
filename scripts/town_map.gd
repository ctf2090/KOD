extends Node2D
class_name TownMap

# Simple 16x16 top-down town map:
# - Drawn procedurally (no external art needed yet).
# - Provides walkability queries for the player controller.

@export var tile_size := 16
@export var map_width := 40
@export var map_height := 30

enum Tile {
	GRASS = 0,
	ROAD = 1,
	SIDEWALK = 2,
	BUILDING = 3,
}

var _tiles: PackedInt32Array = PackedInt32Array()

func _ready() -> void:
	_generate()
	queue_redraw()

func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_width and cell.y < map_height

func tile_at(cell: Vector2i) -> int:
	if not in_bounds(cell):
		return Tile.BUILDING
	return _tiles[cell.y * map_width + cell.x]

func is_walkable(cell: Vector2i) -> bool:
	var t := tile_at(cell)
	return t == Tile.ROAD or t == Tile.SIDEWALK

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * tile_size, cell.y * tile_size)

func cell_center(cell: Vector2i) -> Vector2:
	return cell_to_world(cell) + Vector2(tile_size * 0.5, tile_size * 0.5)

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / tile_size)), int(floor(pos.y / tile_size)))

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

func _draw() -> void:
	# Colors kept intentionally simple; we can swap to real pixel art tiles later.
	var c_grass := Color("#2f8f2f")
	var c_grass_detail := Color("#256f25")
	var c_road := Color("#3a3a3a")
	var c_road_line := Color("#c9c47a")
	var c_sidewalk := Color("#9a9a9a")
	var c_building := Color("#7a3f2a")
	var c_building_roof := Color("#9b4f35")

	for y in range(map_height):
		for x in range(map_width):
			var cell := Vector2i(x, y)
			var t := tile_at(cell)
			var pos := cell_to_world(cell)
			var rect := Rect2(pos, Vector2(tile_size, tile_size))

			match t:
				Tile.GRASS:
					draw_rect(rect, c_grass, true)
					# Cheap "texture": a single dot pattern.
					if (x + y) % 3 == 0:
						draw_rect(Rect2(pos + Vector2(5, 5), Vector2(2, 2)), c_grass_detail, true)
				Tile.ROAD:
					draw_rect(rect, c_road, true)
					# Lane markings on the center cross.
					if (x == map_width / 2 or y == map_height / 2) and ((x + y) % 2 == 0):
						draw_rect(Rect2(pos + Vector2(7, 2), Vector2(2, tile_size - 4)), c_road_line, true)
				Tile.SIDEWALK:
					draw_rect(rect, c_sidewalk, true)
					draw_rect(Rect2(pos + Vector2(2, 2), Vector2(tile_size - 4, tile_size - 4)), Color("#b5b5b5"), false, 1.0)
				Tile.BUILDING:
					draw_rect(rect, c_building, true)
					draw_rect(Rect2(pos + Vector2(1, 1), Vector2(tile_size - 2, 4)), c_building_roof, true)
					draw_rect(Rect2(pos + Vector2(4, 7), Vector2(3, 3)), Color("#ffd27d"), true) # window
					draw_rect(Rect2(pos + Vector2(9, 7), Vector2(3, 3)), Color("#ffd27d"), true) # window
				_:
					draw_rect(rect, Color.MAGENTA, true)

