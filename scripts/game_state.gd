extends Node

# Minimal cross-scene state for entering/exiting interiors.

var _has_spawn_cell := false
var _spawn_cell := Vector2i.ZERO

var _return_scene_path := ""
var _return_cell := Vector2i.ZERO

func set_spawn_cell(cell: Vector2i) -> void:
	_has_spawn_cell = true
	_spawn_cell = cell

func consume_spawn_cell(default_cell: Vector2i) -> Vector2i:
	if not _has_spawn_cell:
		return default_cell
	_has_spawn_cell = false
	return _spawn_cell

func set_return_target(scene_path: String, cell: Vector2i) -> void:
	_return_scene_path = scene_path
	_return_cell = cell

func has_return_target() -> bool:
	return _return_scene_path != ""

func return_scene_path() -> String:
	return _return_scene_path

func return_cell() -> Vector2i:
	return _return_cell
