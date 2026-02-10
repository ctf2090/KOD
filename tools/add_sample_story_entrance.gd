extends SceneTree

const SCENE_PATH := "res://main.tscn"
const CELL := Vector2i(21, 15)

func _initialize() -> void:
	var ps := load(SCENE_PATH) as PackedScene
	if ps == null:
		push_error("Failed to load scene: %s" % SCENE_PATH)
		quit(1)
		return

	var root := ps.instantiate()
	var sb := root.get_node_or_null("StoryBuildings") as TileMapLayer
	var se := root.get_node_or_null("StoryEntrances") as TileMapLayer
	if sb == null or se == null:
		push_error("Scene must have StoryBuildings and StoryEntrances TileMapLayer nodes.")
		quit(1)
		return

	if sb.tile_set != null:
		var sid_b := sb.tile_set.get_source_id(0)
		sb.set_cell(CELL, sid_b, Vector2i(0, 0), 0)

	if se.tile_set != null:
		var sid_e := se.tile_set.get_source_id(0)
		se.set_cell(CELL, sid_e, Vector2i(0, 0), 0)

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		push_error("Failed to pack scene (err=%s)" % str(err))
		quit(1)
		return

	err = ResourceSaver.save(packed, SCENE_PATH)
	if err != OK:
		push_error("Failed to save scene (err=%s)" % str(err))
		quit(1)
		return

	print("Placed sample story entrance at: ", CELL)
	quit(0)

