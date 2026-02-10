extends Node2D
class_name InteriorMap

@export var tile_size := 16
@export var map_width := 20
@export var map_height := 15
@export var floor_layer_path: NodePath
@export var exit_layer_path: NodePath

var _floor: TileMapLayer = null
var _exit: TileMapLayer = null

func _ready() -> void:
	_floor = get_node_or_null(floor_layer_path) as TileMapLayer
	_exit = get_node_or_null(exit_layer_path) as TileMapLayer

	# Seed a visible floor if none was painted yet.
	if _floor != null and _floor.get_used_rect().size == Vector2i.ZERO:
		_seed_floor()
	if _exit != null and _exit.get_used_rect().size == Vector2i.ZERO:
		_seed_exit()

func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < map_width and cell.y < map_height

func is_walkable(cell: Vector2i) -> bool:
	return in_bounds(cell)

func cell_center(cell: Vector2i) -> Vector2:
	if _floor != null:
		return _floor_local_to_parent_pos(_floor.map_to_local(cell))
	return Vector2(cell.x * tile_size + tile_size * 0.5, cell.y * tile_size + tile_size * 0.5)

func world_to_cell(pos: Vector2) -> Vector2i:
	if _floor != null:
		return _floor.local_to_map(_parent_pos_to_floor_local(pos))
	return Vector2i(int(floor(pos.x / tile_size)), int(floor(pos.y / tile_size)))

func on_player_entered_cell(_player: Node, cell: Vector2i) -> void:
	if _exit == null:
		return
	if _exit.get_cell_source_id(cell) == -1:
		return

	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		push_warning("InteriorMap: GameState autoload not found; ignoring exit.")
		return
	if not gs.has_return_target():
		push_warning("InteriorMap: no return target set; ignoring exit.")
		return

	gs.set_spawn_cell(gs.return_cell())
	# Defer scene changes to avoid "busy adding/removing children" errors.
	get_tree().call_deferred("change_scene_to_file", gs.return_scene_path())

func _seed_floor() -> void:
	if _floor == null or _floor.tile_set == null:
		return
	var sid := _floor.tile_set.get_source_id(0)
	# Default to tile (2,0) which is the white tile icon in our ground atlas.
	var atlas := Vector2i(2, 0)
	for y in range(map_height):
		for x in range(map_width):
			_floor.set_cell(Vector2i(x, y), sid, atlas, 0)

func _seed_exit() -> void:
	if _exit == null or _exit.tile_set == null:
		return
	var sid := _exit.tile_set.get_source_id(0)
	_exit.set_cell(Vector2i(1, map_height - 2), sid, Vector2i(0, 0), 0)

func _floor_local_to_parent_pos(floor_local: Vector2) -> Vector2:
	var gpos := _floor.to_global(floor_local)
	var p := get_parent() as Node2D
	if p != null:
		return p.to_local(gpos)
	return gpos

func _parent_pos_to_floor_local(parent_pos: Vector2) -> Vector2:
	var p := get_parent() as Node2D
	var gpos := parent_pos
	if p != null:
		gpos = p.to_global(parent_pos)
	return _floor.to_local(gpos)
