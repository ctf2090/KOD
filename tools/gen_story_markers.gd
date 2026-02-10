extends SceneTree

# Generates tiny 16x16 marker atlases and matching TileSets:
# - Story entrance icon (one tile)
# - Exit icon (one tile)

const OUT_DIR := "res://assets/tiles"
const OUT_ENT_PNG := OUT_DIR + "/story_entrance_atlas.png"
const OUT_EXIT_PNG := OUT_DIR + "/story_exit_atlas.png"
const OUT_ENT_TILESET := OUT_DIR + "/story_entrance_tileset.tres"
const OUT_EXIT_TILESET := OUT_DIR + "/story_exit_tileset.tres"

const TILE := Vector2i(16, 16)

func _initialize() -> void:
	_ensure_dir(OUT_DIR)
	var ent_img := _generate_entrance_png()
	var exit_img := _generate_exit_png()
	ent_img.save_png(OUT_ENT_PNG)
	exit_img.save_png(OUT_EXIT_PNG)

	_save_tileset(ent_img, OUT_ENT_TILESET)
	_save_tileset(exit_img, OUT_EXIT_TILESET)

	print("Wrote: ", OUT_ENT_PNG)
	print("Wrote: ", OUT_EXIT_PNG)
	print("Wrote: ", OUT_ENT_TILESET)
	print("Wrote: ", OUT_EXIT_TILESET)
	quit(0)

func _ensure_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs)

func _generate_entrance_png() -> Image:
	var img := Image.create(TILE.x, TILE.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var outline := Color("#1a1a1a")
	var door := Color("#7a3f2a")
	var door2 := Color("#9b4f35")
	var knob := Color("#ffd27d")

	_fill_rect(img, Vector2i(4, 2), Vector2i(8, 12), door)
	_fill_rect(img, Vector2i(5, 3), Vector2i(6, 4), door2)
	_fill_rect(img, Vector2i(5, 8), Vector2i(6, 5), door2)
	_fill_rect(img, Vector2i(10, 8), Vector2i(1, 1), knob)
	_outline_rect(img, Vector2i(4, 2), Vector2i(8, 12), outline)
	return img

func _generate_exit_png() -> Image:
	var img := Image.create(TILE.x, TILE.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var outline := Color("#1a1a1a")
	var base := Color("#2a8f2a")
	var arrow := Color("#dff1ff")

	_fill_rect(img, Vector2i(2, 2), Vector2i(12, 12), base)
	_outline_rect(img, Vector2i(2, 2), Vector2i(12, 12), outline)

	# Arrow pointing down-left (simple "leave" indicator).
	for i in range(0, 6):
		img.set_pixel(8, 4 + i, arrow)
	for i in range(0, 5):
		img.set_pixel(7 - i, 9, arrow)
	img.set_pixel(3, 8, arrow)
	img.set_pixel(3, 10, arrow)
	img.set_pixel(4, 8, arrow)
	img.set_pixel(4, 10, arrow)
	return img

func _save_tileset(img: Image, out_path: String) -> void:
	var ts := TileSet.new()
	ts.tile_size = TILE
	var src := TileSetAtlasSource.new()
	src.texture = ImageTexture.create_from_image(img)
	src.texture_region_size = TILE
	src.create_tile(Vector2i(0, 0))
	ts.add_source(src)
	var err := ResourceSaver.save(ts, out_path)
	if err != OK:
		push_error("Failed to save tileset to %s (err=%s)" % [out_path, str(err)])
		quit(1)

func _fill_rect(img: Image, pos: Vector2i, size: Vector2i, col: Color) -> void:
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			img.set_pixel(x, y, col)

func _outline_rect(img: Image, pos: Vector2i, size: Vector2i, col: Color) -> void:
	for x in range(pos.x, pos.x + size.x):
		img.set_pixel(x, pos.y, col)
		img.set_pixel(x, pos.y + size.y - 1, col)
	for y in range(pos.y, pos.y + size.y):
		img.set_pixel(pos.x, y, col)
		img.set_pixel(pos.x + size.x - 1, y, col)

