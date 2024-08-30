class_name Chunks
extends Node2D

const chunk_scene: PackedScene = preload("res://generation/Chunk.tscn");

var queue: Array[Chunk] = [];
var thread: Thread = Thread.new();
var semaphore: Semaphore = Semaphore.new();

func generate() -> void:
	var index: int = 0;
	var total: float = float(World.height * World.width);
	for y in range(0, World.height):
		for x in range(0, World.width):
			var chunk: Chunk = chunk_scene.instantiate();
			chunk.position.y = 512 * y;
			chunk.position.x = 512 * x;
			chunk.id = index;
			chunk.iterator = index * 1024;
			chunk.name = str(index);
			chunk.set_unique_name_in_owner(true);
			var tile_index: int = chunk.iterator;
			for tile in chunk.get_children() as Array[Tile]:
				tile.enable(Tiles.on(tile_index), Tiles.model_on(tile_index));
				tile.x = floor(tile.global_position.x / 16.0);
				tile.y = floor(tile.global_position.y / 16.0);
				tile_index += 1;
			call_deferred_thread_group("add_child", chunk, true);
			index += 1;
			Loading.update(5 + (index / total) * 95.0, "Carregando mundo . . .");
			semaphore.wait();
	finished.call_deferred();

func finished() -> void:
	thread.wait_to_finish();
	process_mode = Node.PROCESS_MODE_INHERIT;
	visible = true;
	World.chunks = self;
	Loading.finish();

func _ready() -> void:
	if !Engine.is_editor_hint():
		thread.start(generate);

func get_chunk_at(x: int, y: int) -> Chunk:
	x = clamp(x, 0, World.width - 1);
	y = clamp(y, 0, World.height - 1);
	var index: int = (y * World.width) + x;
	return get_chunk_on(index);
func get_chunk_on(index: int) -> Chunk:
	if index < 0 || index >= get_child_count(): return null;
	return get_children()[index];

func _on_child_entered_tree(node: Node) -> void:
	if !node.is_node_ready(): await node.ready;
	semaphore.post();
