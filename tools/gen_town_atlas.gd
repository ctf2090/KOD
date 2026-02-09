extends SceneTree

# Generates a tiny 16x16 tile atlas for the town map so we can use TileMapLayer
# without depending on external art yet.

const OUT_DIR := "res://assets/tiles"
const OUT_PNG := OUT_DIR + "/town_atlas.png"

const TILE := 16
const COLS := 4
const ROWS := 1

func _initialize() -> void:
	_ensure_dir(OUT_DIR)
	_generate_png()
	print("Wrote: ", OUT_PNG)
	quit(0)

func _ensure_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs)

func _generate_png() -> void:
	var w := TILE * COLS
	var h := TILE * ROWS
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tile 0: grass
	_draw_tile_grass(img, 0, 0)
	# Tile 1: road
	_draw_tile_road(img, 1, 0)
	# Tile 2: sidewalk
	_draw_tile_sidewalk(img, 2, 0)
	# Tile 3: building
	_draw_tile_building(img, 3, 0)

	img.save_png(OUT_PNG)

func _tile_origin(tx: int, ty: int) -> Vector2i:
	return Vector2i(tx * TILE, ty * TILE)

func _fill_rect(img: Image, pos: Vector2i, size: Vector2i, col: Color) -> void:
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			img.set_pixel(x, y, col)

func _draw_tile_grass(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var c0 := Color("#2f8f2f")
	var c1 := Color("#256f25")
	_fill_rect(img, o, Vector2i(TILE, TILE), c0)
	for y in range(0, TILE, 3):
		for x in range((y / 3) % 3, TILE, 3):
			img.set_pixel(o.x + x, o.y + y, c1)

func _draw_tile_road(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var asphalt := Color("#3a3a3a")
	var line := Color("#c9c47a")
	_fill_rect(img, o, Vector2i(TILE, TILE), asphalt)
	# center dashed line
	for y in range(2, TILE - 2):
		if (y % 4) < 2:
			img.set_pixel(o.x + (TILE / 2), o.y + y, line)

func _draw_tile_sidewalk(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var c0 := Color("#9a9a9a")
	var c1 := Color("#b5b5b5")
	_fill_rect(img, o, Vector2i(TILE, TILE), c0)
	# inner border
	for x in range(2, TILE - 2):
		img.set_pixel(o.x + x, o.y + 2, c1)
		img.set_pixel(o.x + x, o.y + (TILE - 3), c1)
	for y in range(2, TILE - 2):
		img.set_pixel(o.x + 2, o.y + y, c1)
		img.set_pixel(o.x + (TILE - 3), o.y + y, c1)

func _draw_tile_building(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var wall := Color("#7a3f2a")
	var roof := Color("#9b4f35")
	var win := Color("#ffd27d")
	_fill_rect(img, o, Vector2i(TILE, TILE), wall)
	_fill_rect(img, o + Vector2i(1, 1), Vector2i(TILE - 2, 4), roof)
	_fill_rect(img, o + Vector2i(4, 7), Vector2i(3, 3), win)
	_fill_rect(img, o + Vector2i(9, 7), Vector2i(3, 3), win)

