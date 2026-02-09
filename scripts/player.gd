extends Node2D

@export var town_map_path: NodePath
@export var start_cell := Vector2i(20, 15)
@export var move_seconds := 0.12

const DIRS_4: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

var _map: TownMap = null
var _cell: Vector2i

var _moving := false
var _move_t := 0.0
var _from_pos := Vector2.ZERO
var _to_pos := Vector2.ZERO

func _ready() -> void:
	var node: Node = get_node_or_null(town_map_path)
	_map = node as TownMap
	if _map == null:
		push_error("Player: town_map_path is not set or not a TownMap.")
		return

	_cell = start_cell
	if not _map.is_walkable(_cell):
		_cell = _find_nearest_walkable(_cell)

	position = _map.cell_center(_cell).round()
	queue_redraw()

func _process(delta: float) -> void:
	if _map == null:
		return

	if _moving:
		_move_t += delta
		var a: float = minf(_move_t / maxf(0.001, move_seconds), 1.0)
		position = _from_pos.lerp(_to_pos, a).round()
		if a >= 1.0:
			_moving = false
		return

	var dir := _input_dir_4()
	if dir == Vector2i.ZERO:
		return

	_try_step(dir)

func _input_dir_4() -> Vector2i:
	# Priority order keeps movement deterministic if multiple keys are pressed.
	if Input.is_action_just_pressed("ui_left"):
		return Vector2i.LEFT
	if Input.is_action_just_pressed("ui_right"):
		return Vector2i.RIGHT
	if Input.is_action_just_pressed("ui_up"):
		return Vector2i.UP
	if Input.is_action_just_pressed("ui_down"):
		return Vector2i.DOWN
	return Vector2i.ZERO

func _try_step(dir: Vector2i) -> void:
	var next := _cell + dir
	if not _map.is_walkable(next):
		return

	_cell = next
	_moving = true
	_move_t = 0.0
	_from_pos = position
	_to_pos = _map.cell_center(_cell).round()

func _find_nearest_walkable(from_cell: Vector2i) -> Vector2i:
	# Small BFS to land the player on a street if start_cell was invalid.
	var q: Array[Vector2i] = []
	var seen: Dictionary[Vector2i, bool] = {}
	q.append(from_cell)
	seen[from_cell] = true

	while q.size() > 0:
		var c: Vector2i = q.pop_front()
		if _map.is_walkable(c):
			return c
		for d: Vector2i in DIRS_4:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			if not _map.in_bounds(n):
				continue
			seen[n] = true
			q.append(n)

	# Fallback to a safe-ish center.
	return Vector2i(_map.map_width / 2, _map.map_height / 2)

func _draw() -> void:
	if _map == null:
		return

	var s := float(_map.tile_size)
	var half := s * 0.5
	# Body
	draw_rect(Rect2(Vector2(-half, -half), Vector2(s, s)), Color("#2d6cff"), true)
	# Outline
	draw_rect(Rect2(Vector2(-half, -half), Vector2(s, s)), Color("#0a1a33"), false, 1.0)
	# "Face" dot to show facing; we'll later add proper sprites/animations.
	draw_rect(Rect2(Vector2(-2, -6), Vector2(4, 4)), Color("#dff1ff"), true)
