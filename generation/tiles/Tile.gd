@tool
class_name Tile
extends StaticBody2D

@export var id: int = 0;
@export var form: int = 0;
@export var type: int = 0;
@export var types: Array[SpriteFrames] = [];

var x: int;
var y: int;

func enable(_type: int = 1, _form: int = 0) -> void:
	type = _type;
	form = _form;
	if type <= 0 || types.size() == 0: return disable();
	elif type > 1:
		pass;
		#sprite.sprite_frames = types[clamp(type - 1, 0, types.size() - 1)];
	if form == 38: $Label.visible = false;
	$Label.text = str(form);
	#sprite.frame = form;
	#sprite.play("default");
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
	set_collision_layer_value(1, form != 38);
	set_collision_mask_value(1, form != 38);
	$Collision.visible = form != 38;
func disable() -> void:
	type = 0;
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;
	set_collision_layer_value(1, false);
	set_collision_mask_value(1, false);
