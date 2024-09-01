class_name PlayerInput
extends MultiplayerSynchronizer

@export var direction: Vector2;

func _ready() -> void:
	set_process(get_multiplayer_authority() == Client.id);

func _process(_delta) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down");
