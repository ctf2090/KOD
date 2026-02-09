extends RefCounted
class_name TownTilesetFactory

const TILE_SIZE := Vector2i(16, 16)

enum AtlasTile {
	GRASS = 0,
	ROAD = 1,
	SIDEWALK = 2,
	BUILDING = 3,
}

static func build(atlas_png_path: String) -> TileSet:
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
	src.create_tile(Vector2i(AtlasTile.GRASS, 0))
	src.create_tile(Vector2i(AtlasTile.ROAD, 0))
	src.create_tile(Vector2i(AtlasTile.SIDEWALK, 0))
	src.create_tile(Vector2i(AtlasTile.BUILDING, 0))

	ts.add_source(src)
	return ts

static func atlas_coords_for(tile_kind: int) -> Vector2i:
	return Vector2i(tile_kind, 0)

static func _load_texture_robust(res_path: String) -> Texture2D:
	# In headless runs, the import pipeline might not be ready. Try ResourceLoader
	# first, then fall back to loading via Image directly.
	var t := load(res_path) as Texture2D
	if t != null:
		return t

	var img := Image.new()
	var err := img.load(res_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)

