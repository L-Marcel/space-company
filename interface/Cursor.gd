extends Control

@export var x: int = 0;
@export var y: int = 0;
@export var static_x: int = 0;
@export var static_y: int = 0;
@export var center: Vector2;
@export var range: int = 3;
@export var icon: TextureRect;
@export var zone: Zone;
@export var machine: PriorityMachine;

@export_group("Textures")
@export var default_texture: Texture;
@export var put_texture: Texture;
@export var destroy_texture: Texture;

func enable_destroy(_x: int, _y: int) -> void:
	x = _x;
	y = _y;
	static_x = x;
	static_y = y;
	position.x = x * 16;
	position.y = y * 16;
	machine.enable("destroy");
func disable_destroy() -> void:
	machine.disable("destroy");
func enable_put() -> void:
	machine.enable("put");
func disable_put() -> void:
	machine.disable("put");

func update_coords() -> void:
	var global_mouse_position: Vector2 = get_global_mouse_position();
	x = floor(global_mouse_position.x / 16);
	y = floor(global_mouse_position.y / 16);

func _on_default_process(_delta: float) -> void:
	update_coords();
	position.x = x * 16;
	position.y = y * 16;
func _on_put_process(_delta: float) -> void:
	update_coords();
	var center_x: int = floor(center.x / 16);
	var center_y: int = floor(center.y / 16);
	x = clamp(x, center_x - 3, center_x + 2);
	y = clamp(y, center_y - 3, center_y + 2);
	position.x = x * 16;
	position.y = y * 16;

func _on_priority_machine_states_changed(currents: Array[StringName]) -> void:
	match currents:
		[]:
			icon.texture = default_texture;
			icon.visible = true;
		[&"destroy"]:
			x = static_x;
			y = static_y;
			position.x = x * 16;
			position.y = y * 16;
			icon.texture = destroy_texture;
			icon.visible = true;
		[&"put"]:
			icon.texture = put_texture;
			icon.visible = true;
