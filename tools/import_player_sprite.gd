extends SceneTree

# Godot does not allow defining functions inside functions.
func _unquote(s: String) -> String:
	if s.length() >= 2 and s.begins_with("\"") and s.ends_with("\""):
		return s.substr(1, s.length() - 2)
	return s

# Headless utility:
# - Loads an external PNG (absolute path)
# - Resizes to 16x16 using nearest-neighbor
# - Saves to a project path (res://...)
#
# Usage (PowerShell):
#   tools/godot.cmd --headless --script tools/import_player_sprite.gd -- --in="C:\\path\\to\\src.png" --out="res://assets/sprites/characters/player.png"

func _initialize() -> void:
	# Only user args (after `--`) to avoid Godot engine flags.
	var args := OS.get_cmdline_user_args()
	var in_path := ""
	var out_path := "res://assets/sprites/characters/player.png"

	for i in range(args.size()):
		var a := str(args[i])
		if a == "--in" and i + 1 < args.size():
			in_path = _unquote(str(args[i + 1]))
		elif a == "--out" and i + 1 < args.size():
			out_path = _unquote(str(args[i + 1]))
		elif a.begins_with("--in="):
			in_path = _unquote(a.substr("--in=".length()))
		elif a.begins_with("--out="):
			out_path = _unquote(a.substr("--out=".length()))

	if in_path.is_empty():
		push_error("Missing --in=... argument.")
		quit(2)
		return

	var img := Image.new()
	var err := img.load(in_path)
	if err != OK:
		push_error("Failed to load input image: %s (err=%s)" % [in_path, str(err)])
		quit(3)
		return

	# Force RGBA to ensure predictable output.
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)

	img.resize(16, 16, Image.INTERPOLATE_NEAREST)

	# Ensure output folder exists.
	var out_dir := out_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(out_dir):
		DirAccess.make_dir_recursive_absolute(out_dir)

	err = img.save_png(out_path)
	if err != OK:
		push_error("Failed to save output image: %s (err=%s)" % [out_path, str(err)])
		quit(4)
		return

	print("Wrote %s" % out_path)
	quit(0)
