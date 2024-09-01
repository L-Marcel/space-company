class_name Map
extends TileMapLayer

var mutex: Mutex = Mutex.new();
var thread: Thread = Thread.new();
var semaphore: Semaphore = Semaphore.new();

signal loaded;

func start() -> void:
	thread.start(generate);
func generate() -> void:
	var index: int = 0;
	var total: float = float(World.height * World.width * 1024);
	for y in range(0, World.height * 32):
		for x in range(0, World.width * 32):
			call_deferred_thread_group(
				"update_cell", x, y, 
				Tiles.on(index), get_atlas_coords(Tiles.atlas_on(index)), index
			);
			if index % 1024 == 1023:
				semaphore.wait();
				Loading.update(5 + (index / total) * 95.0, "Carregando mundo . . .");
				OS.delay_msec(10);
			index += 1;
	Loading.update(100.0, "Inicializando mundo . . .");
	OS.delay_msec(1000);
	call_deferred_thread_group("prepare");
func update_cell(x: int, y: int, id: int, coords: Vector2i, index: int) -> void:
	if id >= 2: set_cell(Vector2i(x, y), 2, coords);
	if index % 1024 == 1023: semaphore.post();
func get_atlas_coords(atlas: int) -> Vector2i:
	if atlas == 0: return Vector2i(0, 3);
	elif atlas < 4: return Vector2i(0, atlas - 1);
	return Vector2i(floor(atlas / 4), atlas % 4);
func prepare() -> void:
	thread.wait_to_finish();
	finish.call_deferred();
	process_mode = Node.PROCESS_MODE_INHERIT;

func finish() -> void:
	visible = true;
	Loading.finish();
	loaded.emit();
func _ready() -> void:
	if Tiles.updated: start();
	else: 
		await Tiles.update;
		start();
