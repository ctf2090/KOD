extends SceneTree

# Generates a tiny 16x16 tile atlas for the town map so we can use TileMapLayer
# without depending on external art yet.

const OUT_DIR := "res://assets/tiles"
const OUT_GROUND_PNG := OUT_DIR + "/ground_atlas.png"
const OUT_BUILDING_PNG := OUT_DIR + "/building_atlas.png"

const TILE := 16
const ROWS := 1

func _initialize() -> void:
	_ensure_dir(OUT_DIR)
	_generate_ground_png()
	_generate_building_png()
	print("Wrote: ", OUT_GROUND_PNG)
	print("Wrote: ", OUT_BUILDING_PNG)
	quit(0)

func _ensure_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs)

func _generate_ground_png() -> void:
	var w := TILE * 4
	var h := TILE * ROWS
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tile 0: grass
	_draw_tile_grass(img, 0, 0)
	# Tile 1: road
	_draw_tile_road(img, 1, 0)
	# Tile 2: white tile icon
	_draw_tile_white_tile(img, 2, 0)
	# Tile 3: red bricks
	_draw_tile_red_brick(img, 3, 0)

	img.save_png(OUT_GROUND_PNG)

func _generate_building_png() -> void:
	var w := TILE * 4
	var h := TILE * ROWS
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	_draw_tile_house(img, 0, 0, Color("#9b4f35"))
	_draw_tile_house(img, 1, 0, Color("#355a9b"))
	_draw_tile_shop(img, 2, 0)
	_draw_tile_tower(img, 3, 0)

	img.save_png(OUT_BUILDING_PNG)

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

func _draw_tile_white_tile(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var base := Color("#f2f2f2")
	var edge := Color("#c7c7c7")
	var shadow := Color("#d9d9d9")
	_fill_rect(img, o, Vector2i(TILE, TILE), base)
	# outer border
	for x in range(0, TILE):
		img.set_pixel(o.x + x, o.y + 0, edge)
		img.set_pixel(o.x + x, o.y + (TILE - 1), edge)
	for y in range(0, TILE):
		img.set_pixel(o.x + 0, o.y + y, edge)
		img.set_pixel(o.x + (TILE - 1), o.y + y, edge)
	# simple "icon" bevel
	for x in range(1, TILE - 1):
		img.set_pixel(o.x + x, o.y + 1, shadow)
	for y in range(1, TILE - 1):
		img.set_pixel(o.x + 1, o.y + y, shadow)
	# subtle grid lines
	for x in range(4, TILE, 4):
		for y in range(2, TILE - 2):
			img.set_pixel(o.x + x, o.y + y, edge)
	for y in range(4, TILE, 4):
		for x in range(2, TILE - 2):
			img.set_pixel(o.x + x, o.y + y, edge)

func _draw_tile_red_brick(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var brick := Color("#b6423a")
	var brick2 := Color("#a83b34")
	var mortar := Color("#d9cbbf")
	_fill_rect(img, o, Vector2i(TILE, TILE), brick)
	# horizontal mortar lines
	for y in range(0, TILE, 4):
		for x in range(0, TILE):
			img.set_pixel(o.x + x, o.y + y, mortar)
	# vertical mortar lines (staggered)
	for row in range(0, TILE, 4):
		var off := 0 if ((row / 4) % 2) == 0 else 3
		for x in range(off, TILE, 6):
			for y in range(row + 1, min(row + 4, TILE)):
				img.set_pixel(o.x + x, o.y + y, mortar)
	# light variation
	for y in range(1, TILE):
		for x in range(1, TILE):
			if img.get_pixel(o.x + x, o.y + y) == brick and ((x + y) % 7) == 0:
				img.set_pixel(o.x + x, o.y + y, brick2)

func _draw_tile_house(img: Image, tx: int, ty: int, roof: Color) -> void:
	var o := _tile_origin(tx, ty)
	var wall := Color("#7a3f2a")
	var win := Color("#ffd27d")
	var door := Color("#4a271b")
	_fill_rect(img, o, Vector2i(TILE, TILE), wall)
	_fill_rect(img, o + Vector2i(1, 1), Vector2i(TILE - 2, 4), roof)
	_fill_rect(img, o + Vector2i(4, 7), Vector2i(3, 3), win)
	_fill_rect(img, o + Vector2i(9, 7), Vector2i(3, 3), win)
	_fill_rect(img, o + Vector2i(7, 11), Vector2i(2, 4), door)

func _draw_tile_shop(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var wall := Color("#6b3a29")
	var awn0 := Color("#d34a4a")
	var awn1 := Color("#f1e7d3")
	var glass := Color("#8fd3ff")
	_fill_rect(img, o, Vector2i(TILE, TILE), wall)
	# awning stripes
	for x in range(1, TILE - 1):
		var c := awn0 if (x % 4) < 2 else awn1
		for y in range(1, 5):
			img.set_pixel(o.x + x, o.y + y, c)
	# big window
	_fill_rect(img, o + Vector2i(2, 7), Vector2i(TILE - 4, 6), glass)
	# base
	_fill_rect(img, o + Vector2i(1, 14), Vector2i(TILE - 2, 1), Color("#2d2d2d"))

func _draw_tile_tower(img: Image, tx: int, ty: int) -> void:
	var o := _tile_origin(tx, ty)
	var stone0 := Color("#6a6a6a")
	var stone1 := Color("#808080")
	var win := Color("#ffd27d")
	_fill_rect(img, o, Vector2i(TILE, TILE), stone0)
	# subtle bricks
	for y in range(2, TILE - 2, 3):
		for x in range(1 + (y / 3) % 2, TILE - 1, 4):
			img.set_pixel(o.x + x, o.y + y, stone1)
	# narrow windows
	_fill_rect(img, o + Vector2i(7, 5), Vector2i(2, 3), win)
	_fill_rect(img, o + Vector2i(7, 10), Vector2i(2, 3), win)
