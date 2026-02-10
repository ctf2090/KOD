extends SceneTree

# Creates a reusable TileSet resource for manual TileMap painting.

const OUT_GROUND_TILESET := "res://assets/tiles/ground_tileset.tres"
const OUT_BUILDINGS_TILESET := "res://assets/tiles/building_tileset.tres"
const GROUND_ATLAS_PNG := "res://assets/tiles/ground_atlas.png"
const BUILDING_ATLAS_PNG := "res://assets/tiles/building_atlas.png"

func _initialize() -> void:
	var factory := preload("res://scripts/town_tileset_factory.gd")
	var ts_ground: TileSet = factory.build_ground(GROUND_ATLAS_PNG)
	if ts_ground == null:
		push_error("Failed to build ground TileSet from atlas: %s" % GROUND_ATLAS_PNG)
		quit(1)
		return

	var err := ResourceSaver.save(ts_ground, OUT_GROUND_TILESET)
	if err != OK:
		push_error("Failed to save TileSet to %s (err=%s)" % [OUT_GROUND_TILESET, str(err)])
		quit(1)
		return

	var ts_buildings: TileSet = factory.build_buildings(BUILDING_ATLAS_PNG)
	if ts_buildings == null:
		push_error("Failed to build buildings TileSet from atlas: %s" % BUILDING_ATLAS_PNG)
		quit(1)
		return

	err = ResourceSaver.save(ts_buildings, OUT_BUILDINGS_TILESET)
	if err != OK:
		push_error("Failed to save TileSet to %s (err=%s)" % [OUT_BUILDINGS_TILESET, str(err)])
		quit(1)
		return

	print("Wrote: ", OUT_GROUND_TILESET)
	print("Wrote: ", OUT_BUILDINGS_TILESET)
	quit(0)
