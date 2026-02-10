extends Resource
class_name StoryBuildingDB

@export var entries: Array[StoryBuildingEntry] = []

func find_entry(cell: Vector2i) -> StoryBuildingEntry:
	for e: StoryBuildingEntry in entries:
		if e != null and e.world_cell == cell:
			return e
	return null

