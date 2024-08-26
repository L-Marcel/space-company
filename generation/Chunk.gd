@tool
class_name Chunk
extends Node2D

var remove: bool = true;
var iterator: int = 0;
@export var id: int = 0:
	set(value):
		id = value;
		iterator = id * 1024;

func _ready() -> void:
	id = int(str(name));
	if Engine.is_editor_hint(): return;
	var line: ChunkLine = get_parent();
	if line is ChunkLine: id += line.id * line.size;
	if World.data.get_size() <= iterator: generate();
	else: fetch();

func generate() -> void:
	var index: int = iterator;
	for tile in get_children() as Array[Tile]:
		var type: int = 0;
		var value = World.noise.get_noise_2d(tile.position.x, tile.position.y);
		if value >= 0: type = 2;
		World.data.resize(index);
		World.data.seek(index);
		index += 1;
		World.data.put_u8(type);
		tile.enable(type);
func fetch() -> void:
	var index: int = iterator;
	for tile in get_children() as Array[Tile]:
		World.data.seek(index);
		index += 1;
		tile.enable(World.data.get_u8());

func enable() -> void:
	visible = true;
	process_mode = Node.PROCESS_MODE_INHERIT;
func disable() -> void:
	visible = false;
	process_mode = Node.PROCESS_MODE_DISABLED;
