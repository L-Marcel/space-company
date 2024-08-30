@tool
class_name Chunk
extends Node2D

var remove: bool = true;
var iterator: int = 0;
var id: int = 0;

func fetch() -> void:
	var index: int = iterator;
	for tile in get_children() as Array[Tile]:
		tile.enable(Tiles.on(index), Tiles.model_on(index));
		index += 1;
func enable() -> void:
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
func disable() -> void:
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;
