class_name PlayerInput
extends MultiplayerSynchronizer

@export var direction: Vector2;
@export var jump: bool;
@export var propulsion: bool;
@export var action: bool;
@export var light: bool;
var need_propulsion: bool = false;

func _ready() -> void:
	set_process(get_multiplayer_authority() == Client.id);

func _process(_delta) -> void:
	direction = Input.get_vector("left", "right", "up", "down");
	jump = Input.is_action_just_pressed("propulsion");
	propulsion = Input.is_action_pressed("propulsion");
	action = Input.is_action_pressed("action");
	light = Input.is_action_just_pressed("light");
	Cursor.center = get_parent().position;
