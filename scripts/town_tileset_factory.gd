extends RefCounted
class_name TownTilesetFactory

const TILE_SIZE := Vector2i(16, 16)

enum GroundAtlasTile { GRASS = 0, ROAD = 1, SIDEWALK = 2 }

# Four variants in the building atlas. These are just visual variants; any
# building tile blocks movement via TownMap's Buildings layer check.
enum BuildingAtlasTile { HOUSE_A = 0, HOUSE_B = 1, SHOP = 2, TOWER = 3 }

static func build(atlas_png_path: String) -> TileSet:
	# Backwards-compatible default: "build" means "build ground tileset".
	return build_ground(atlas_png_path)

static func build_ground(atlas_png_path: String) -> TileSet:
	return _build_atlas_tileset(atlas_png_path, 3)

static func build_buildings(atlas_png_path: String) -> TileSet:
	return _build_atlas_tileset(atlas_png_path, 4)

static func ground_atlas_coords_for(tile_kind: int) -> Vector2i:
	return Vector2i(tile_kind, 0)

static func building_atlas_coords_for(tile_kind: int) -> Vector2i:
	return Vector2i(tile_kind, 0)

static func _build_atlas_tileset(atlas_png_path: String, cols: int) -> TileSet:
	var tex := _load_texture_robust(atlas_png_path)
	if tex == null:
		push_error("TownTilesetFactory: failed to load atlas: %s" % atlas_png_path)
		return null

	var ts := TileSet.new()
	ts.tile_size = TILE_SIZE

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = TILE_SIZE

	# Ensure tiles exist in the atlas source.
	for x in range(cols):
		src.create_tile(Vector2i(x, 0))

	ts.add_source(src)
	return ts

static func _load_texture_robust(res_path: String) -> Texture2D:
	# In headless runs, the import pipeline might not be ready. Try ResourceLoader
	# first, then fall back to loading via Image directly.
	# Avoid noisy "No loader found" errors for PNGs that don't have a `.import`
	# alongside them (common when we generate atlases via script).
	if FileAccess.file_exists(res_path + ".import"):
		var t := load(res_path) as Texture2D
		if t != null:
			return t

	var img := Image.new()
	var err := img.load(res_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)
