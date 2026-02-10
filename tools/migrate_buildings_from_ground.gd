extends SceneTree

# One-off migration:
# - Old: Ground tile atlas had BUILDING at atlas x=3.
# - New: Buildings will get its own atlas/tileset.
# This script moves any atlas x=3 cells from Ground -> Buildings (atlas x=0).

const SCENE_PATH := "res://main.tscn"

func _initialize() -> void:
	var ps := load(SCENE_PATH) as PackedScene
	if ps == null:
		push_error("Failed to load scene: %s" % SCENE_PATH)
		quit(1)
		return

	var root := ps.instantiate()
	var ground := root.get_node_or_null("Ground") as TileMapLayer
	var buildings := root.get_node_or_null("Buildings") as TileMapLayer
	if ground == null or buildings == null:
		push_error("Scene must have Ground and Buildings TileMapLayer nodes.")
		quit(1)
		return

	var buildings_source_id := -1
	if buildings.tile_set != null:
		buildings_source_id = buildings.tile_set.get_source_id(0)

	var moved := 0
	var used := ground.get_used_cells()
	for cell: Vector2i in used:
		var sid := ground.get_cell_source_id(cell)
		if sid == -1:
			continue
		var atlas := ground.get_cell_atlas_coords(cell)
		if atlas != Vector2i(3, 0):
			continue

		# Remove from ground, add to buildings.
		ground.erase_cell(cell)
		# If Buildings already has its own TileSet, use its source id; otherwise
		# fall back to the Ground source id.
		var out_sid := buildings_source_id if buildings_source_id != -1 else sid
		buildings.set_cell(cell, out_sid, Vector2i(0, 0), 0)
		moved += 1

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

	print("Moved building cells: ", moved)
	quit(0)
