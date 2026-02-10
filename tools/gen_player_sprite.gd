extends SceneTree

# Generates a tiny 16x16 player sprite PNG.
#
# We keep it procedural so the project works without external art; you can
# replace the PNG later with real pixel art.

const OUT_DIR := "res://assets/sprites"
const OUT_PNG := OUT_DIR + "/player.png"

const S := 16

func _initialize() -> void:
	_ensure_dir(OUT_DIR)
	_generate_png()
	print("Wrote: ", OUT_PNG)
	quit(0)

func _ensure_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	DirAccess.make_dir_recursive_absolute(abs)

func _generate_png() -> void:
	var img := Image.create(S, S, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var outline := Color("#0a1a33")
	var shirt := Color("#2d6cff")
	var pants := Color("#213155")
	var skin := Color("#ffd7b5")
	var hair := Color("#2a2a2a")
	var eye := Color("#dff1ff")

	# Body fill.
	_fill_rect(img, Vector2i(4, 4), Vector2i(8, 7), shirt)
	_fill_rect(img, Vector2i(5, 11), Vector2i(6, 4), pants)

	# Head.
	_fill_rect(img, Vector2i(5, 1), Vector2i(6, 4), skin)
	_fill_rect(img, Vector2i(5, 1), Vector2i(6, 2), hair)
	img.set_pixel(7, 3, eye)
	img.set_pixel(9, 3, eye)

	# Simple outline.
	_outline_rect(img, Vector2i(4, 4), Vector2i(8, 11), outline)
	_outline_rect(img, Vector2i(5, 1), Vector2i(6, 4), outline)

	img.save_png(OUT_PNG)

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

