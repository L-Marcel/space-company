extends Node

const chunks_scene: PackedScene = preload("res://generation/Chunks.tscn");

var width: int = 10;
var height: int = 3;

var chunks: Chunks:
	set(value):
		chunks = value;
		if chunks:
			start();
			update();
var enabled_chunks: Dictionary = {};

var player: Player;
var semaphore: Semaphore;
var thread: Thread;

func _ready() -> void:
	randomize();

@rpc("authority", "call_local", "reliable")
func fetch(width: int, height: int, _seed: int, bytes: PackedByteArray) -> void:
	width = width;
	height = height;
	Tiles.fetch(_seed, bytes);

func convert_size(_size: int) -> Vector2i:
	match _size:
		0: return Vector2i(4, 5);
		1: return Vector2i(8, 10);
		3: return Vector2i(20, 40);
		_: return Vector2i(10, 20);
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
	if !player: return;
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
