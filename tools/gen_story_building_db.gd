extends SceneTree

const OUT_DIR := "res://data"
const OUT_DB := OUT_DIR + "/story_buildings.tres"

func _initialize() -> void:
	_ensure_dir(OUT_DIR)

	var db := StoryBuildingDB.new()
	db.entries = []

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

