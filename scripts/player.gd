extends Node2D

@export var town_map_path: NodePath
@export var start_cell := Vector2i(20, 15)
@export var move_seconds := 0.12
@export var sprite_path: NodePath = NodePath("Sprite2D")

const DIRS_4: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const MOVE_UP: StringName = &"move_up"
const MOVE_DOWN: StringName = &"move_down"

var _map: Node = null
var _cell: Vector2i

var _moving := false
var _move_t := 0.0
var _from_pos := Vector2.ZERO
var _to_pos := Vector2.ZERO
var _sprite: Sprite2D = null

func _ready() -> void:
	_ensure_move_actions()

	var node: Node = get_node_or_null(town_map_path)
	_map = node
	if _map == null:
		push_error("Player: town_map_path is not set.")
		return
	if not _map.has_method("is_walkable") or not _map.has_method("cell_center") or not _map.has_method("in_bounds"):
		push_error("Player: town_map_path must expose is_walkable/cell_center/in_bounds methods.")
		return

	_sprite = get_node_or_null(sprite_path) as Sprite2D
	if _sprite != null:
		_sprite.centered = true
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var gs := get_node_or_null("/root/GameState")
	_cell = (gs.consume_spawn_cell(start_cell) as Vector2i) if gs != null and gs.has_method("consume_spawn_cell") else start_cell
	if not _map.call("is_walkable", _cell):
		_cell = _find_nearest_walkable(_cell)

	position = (_map.call("cell_center", _cell) as Vector2).round()
	# Don't trigger story entrances on spawn; only when the player steps onto a
	# tile. This avoids starting the game inside an interior and prevents
	# immediate re-entry loops when returning to the world.

func _process(delta: float) -> void:
	if _map == null:
		return

	if _moving:
		_move_t += delta
		var a: float = minf(_move_t / maxf(0.001, move_seconds), 1.0)
		position = _from_pos.lerp(_to_pos, a).round()
		if a >= 1.0:
			_moving = false
			_notify_cell_entered()
		return

	var dir := _input_dir_4()
	if dir == Vector2i.ZERO:
		return

	_try_step(dir)

func _input_dir_4() -> Vector2i:
	# Priority order keeps movement deterministic if multiple keys are pressed.
	if Input.is_action_pressed(MOVE_LEFT):
		return Vector2i.LEFT
	if Input.is_action_pressed(MOVE_RIGHT):
		return Vector2i.RIGHT
	if Input.is_action_pressed(MOVE_UP):
		return Vector2i.UP
	if Input.is_action_pressed(MOVE_DOWN):
		return Vector2i.DOWN
	return Vector2i.ZERO

func _ensure_move_actions() -> void:
	# Don't alter the built-in ui_* actions; instead provide gameplay actions
	# so WASD won't unexpectedly change editor/menu navigation.
	_ensure_action_has_keys(MOVE_LEFT, [KEY_A, KEY_LEFT])
	_ensure_action_has_keys(MOVE_RIGHT, [KEY_D, KEY_RIGHT])
	_ensure_action_has_keys(MOVE_UP, [KEY_W, KEY_UP])
	_ensure_action_has_keys(MOVE_DOWN, [KEY_S, KEY_DOWN])

func _ensure_action_has_keys(action: StringName, keys: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for k: int in keys:
		if _action_has_key(action, k):
			continue
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		ev.keycode = k
		InputMap.action_add_event(action, ev)

func _action_has_key(action: StringName, key: int) -> bool:
	for ev in InputMap.action_get_events(action):
		var kev := ev as InputEventKey
		if kev == null:
			continue
		if kev.physical_keycode == key or kev.keycode == key:
			return true
	return false

func _try_step(dir: Vector2i) -> void:
	var next := _cell + dir
	if not _map.call("is_walkable", next):
		return

	_cell = next
	_moving = true
	_move_t = 0.0
	_from_pos = position
	_to_pos = (_map.call("cell_center", _cell) as Vector2).round()

func _find_nearest_walkable(from_cell: Vector2i) -> Vector2i:
	# Small BFS to land the player on a street if start_cell was invalid.
	var q: Array[Vector2i] = []
	var seen: Dictionary[Vector2i, bool] = {}
	q.append(from_cell)
	seen[from_cell] = true

	while q.size() > 0:
		var c: Vector2i = q.pop_front()
		if _map.call("is_walkable", c):
			return c
		for d: Vector2i in DIRS_4:
			var n: Vector2i = c + d
			if seen.has(n):
				continue
			if not _map.call("in_bounds", n):
				continue
			seen[n] = true
			q.append(n)

	# Fallback to a safe-ish center.
	return Vector2i(0, 0)

func _notify_cell_entered() -> void:
	if _map != null and _map.has_method("on_player_entered_cell"):
		_map.call("on_player_entered_cell", self, _cell)
