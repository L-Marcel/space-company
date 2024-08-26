class_name Player
extends CharacterBody2D

const SPEED = 300.0;

@export var input: PlayerInput;

static var players: Array[Player] = [];

var chunk: Vector2i:
	set(value):
		if chunk != value:
			chunk = value;
			if multiplayer.get_unique_id() == id: update_chunks();
var chunks: Array[Chunk] = [];
var id: int = 1:
	set(value):
		id = value;
		input.set_multiplayer_authority(id);

func update_chunks() -> void:
	if !World.chunks: return;
	chunks.clear();
	var x_range: Array = range(chunk.x -  1, chunk.x + 2);
	for y in range(chunk.y - 1, chunk.y + 2):
		for x in x_range:
			var _chunk: Chunk = World.chunks.get_chunk_at(x, y);
			if _chunk && !chunks.has(_chunk):
				chunks.append(_chunk);
	World.update();

func _ready() -> void:
	var is_server: bool = multiplayer.is_server();
	set_process(is_server);
	set_physics_process(is_server);
	if is_server: World.update();
	if multiplayer.get_unique_id() == id:
		$Camera.enabled = true;
		World.player = self;
	$Control/Label.text = str(id);
	players.append(self);
	tree_exiting.connect(_on_tree_exiting);
func _process(_delta: float) -> void:
	var direction: Vector2 = input.direction;
	if direction: velocity = direction * SPEED;
	else: velocity = velocity.move_toward(Vector2.ZERO, SPEED);
	chunk = Vector2i(
		floor(global_position.x / 512),
		floor(global_position.y / 512)
	);
func _physics_process(_delta: float) -> void:
	move_and_slide();
func _on_tree_exiting() -> void:
	players.erase(self);
