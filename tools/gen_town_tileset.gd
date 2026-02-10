extends SceneTree

# Creates a reusable TileSet resource for manual TileMap painting.

const OUT_TILESET := "res://assets/tiles/town_tileset.tres"
const ATLAS_PNG := "res://assets/tiles/ground_atlas.png"

func _initialize() -> void:
	var factory := preload("res://scripts/town_tileset_factory.gd")
	var ts: TileSet = factory.build(ATLAS_PNG)
	if ts == null:
		push_error("Failed to build TileSet from atlas: %s" % ATLAS_PNG)
		quit(1)
		return

	var err := ResourceSaver.save(ts, OUT_TILESET)
	if err != OK:
		push_error("Failed to save TileSet to %s (err=%s)" % [OUT_TILESET, str(err)])
		quit(1)
		return

	print("Wrote: ", OUT_TILESET)
	quit(0)
