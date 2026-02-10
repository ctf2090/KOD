extends Resource
class_name StoryBuildingEntry

@export var world_cell := Vector2i.ZERO
@export var interior_scene_path := ""
@export var interior_spawn_cell := Vector2i(8, 8)

# Where to return in the world when exiting.
@export var return_scene_path := "res://main.tscn"
@export var return_cell := Vector2i.ZERO

