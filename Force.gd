extends Button

func _on_pressed() -> void:
	DirAccess.remove_absolute("user://world");
	var chunks: Node2D = get_tree().get_first_node_in_group("chunks");
	for child in chunks.get_children():
		if child is Chunk:
			child.create();
