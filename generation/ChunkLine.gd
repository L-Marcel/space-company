@tool
class_name ChunkLine
extends Node2D

const chunk_scene: PackedScene = preload("res://generation/Chunk.tscn");

@export var size: int = 10;
@export var id: int = 0:
	set(value):
		id = value;

func _enter_tree() -> void:
	if !Engine.is_editor_hint():
		for x in range(0, size):
			var chunk: Chunk = chunk_scene.instantiate();
			chunk.position.x = 512 * x;
			chunk.name = str(x);
			chunk.set_unique_name_in_owner(true);
			add_child(chunk);
func _ready() -> void:
	if Engine.is_editor_hint() && name != "ChunkLine":
		id = int(str(name));
		set_unique_name_in_owner(true);
