@tool
class_name Tile
extends StaticBody2D

@export var id: int = 0;
@export var type: int = 0;

func _ready() -> void:
	if Engine.is_editor_hint() && name != "Tile":
		id = int(str(name));

func enable(_type: int = 1) -> void:
	type = _type;
	if _type <= 0: return disable();
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
	set_collision_layer_value(1, true);
	set_collision_mask_value(1, true);

func disable() -> void:
	type = 0;
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;
	set_collision_layer_value(1, false);
	set_collision_mask_value(1, false);
