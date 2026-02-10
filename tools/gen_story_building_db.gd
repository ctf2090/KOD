extends SceneTree

const OUT_DIR := "res://data"
const OUT_DB := OUT_DIR + "/story_buildings.tres"

func _initialize() -> void:
	_ensure_dir(OUT_DIR)

	var db := StoryBuildingDB.new()
	db.entries = []

	# Sample entry so the pipeline works out of the box.
	# Paint a story entrance at this cell in the world to test.
	var e := StoryBuildingEntry.new()
	e.world_cell = Vector2i(21, 15)
	e.interior_scene_path = "res://scenes/interiors/interior_template.tscn"
	e.interior_spawn_cell = Vector2i(8, 8)
	e.return_scene_path = "res://main.tscn"
	e.return_cell = e.world_cell
	db.entries.append(e)

	var err := ResourceSaver.save(db, OUT_DB)
	if err != OK:
		push_error("Failed to save DB to %s (err=%s)" % [OUT_DB, str(err)])
		quit(1)
		return

	print("Wrote: ", OUT_DB)
	quit(0)

func _ensure_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs)
