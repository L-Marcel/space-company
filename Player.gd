class_name Player
extends CharacterBody2D

const SPEED = 300.0;

@export var input: PlayerInput;
@export var camera: Camera2D;

static var players: Array[Player] = [];

var id: int = 1:
	set(value):
		id = value;
		input.set_multiplayer_authority(id);

func _ready() -> void:
	var is_server: bool = multiplayer.is_server();
	set_process(is_server);
	set_physics_process(is_server);
	if Client.id != id: camera.queue_free();
	$Control/Label.text = str(id);
	players.append(self);
	tree_exiting.connect(_on_tree_exiting);
func _process(_delta: float) -> void:
	var direction: Vector2 = input.direction;
	if direction: velocity = direction * SPEED;
	else: velocity = velocity.move_toward(Vector2.ZERO, SPEED);
func _physics_process(_delta: float) -> void:
	move_and_slide();
func _on_tree_exiting() -> void:
	players.erase(self);
