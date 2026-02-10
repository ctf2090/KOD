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
		# We keep the same source id; later we will swap Buildings to a new tileset.
		buildings.set_cell(cell, sid, Vector2i(0, 0), 0)
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

