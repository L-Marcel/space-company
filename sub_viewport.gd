@tool
extends SubViewport

func _ready() -> void:
	world_2d = get_viewport().world_2d;

func update() -> void:
	world_2d = get_viewport().world_2d;
