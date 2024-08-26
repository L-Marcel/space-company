extends Node

const small_chunks: PackedScene = preload("res://generation/SmallWorldChunks.tscn");

var noise: FastNoiseLite = FastNoiseLite.new();
var data: StreamPeerBuffer = StreamPeerBuffer.new();

var chunks: Chunks:
	set(value):
		chunks = value;
		start();
		update();
var enabled_chunks: Dictionary = {};

var player: Player;
var semaphore: Semaphore;
var thread: Thread;

func _ready() -> void:
	randomize();
func generate() -> void:
	noise.seed = randi();
	noise.fractal_octaves = 3;
	if !DirAccess.dir_exists_absolute("user://world"): 
		DirAccess.make_dir_absolute("user://world");
	var game: Node2D = get_tree().get_first_node_in_group("game");
	var world: Node2D = small_chunks.instantiate();
	game.add_child(world);
	if !world.is_node_ready():
		await world.ready;
	update();
	#var file: FileAccess = FileAccess.open("user://world/data.txt", FileAccess.ModeFlags.WRITE);
	#file.store_buffer(data.data_array);
	#file.close();
	
@rpc("authority", "call_local", "reliable")
func fetch(_seed: int, bytes: PackedByteArray) -> void:
	noise.seed = _seed;
	noise.fractal_octaves = 3;
	var game: Node2D = get_tree().get_first_node_in_group("game");
	var world: Node2D = small_chunks.instantiate();
	data.put_data(bytes);
	game.add_child(world);

func start() -> void:
	semaphore = Semaphore.new();
	thread = Thread.new();
	thread.start(rotine);

func update() -> void:
	if semaphore: semaphore.post();
func rotine() -> void:
	semaphore.wait();
	prepare();
	create();
	cleanup();
	rotine();
func prepare() -> void:
	for id in enabled_chunks: 
		enabled_chunks[id].remove = true;
func create() -> void:
	for chunk in player.chunks:
		chunk.remove = false;
		enabled_chunks[chunk.id] = chunk;
		chunk.enable.call_deferred();
func cleanup() -> void:
	for id in enabled_chunks.keys():
		var chunk: Chunk = enabled_chunks[id];
		if chunk.remove:
			chunk.disable.call_deferred();
			enabled_chunks.erase(id);
