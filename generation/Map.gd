class_name Map
extends TileMapLayer

var mutex: Mutex = Mutex.new();
var thread: Thread = Thread.new();
var semaphore: Semaphore = Semaphore.new();

static var _map: Map;

static func get_atlas_coords(atlas: int) -> Vector2i:
	if atlas == 0: return Vector2i(0, 3);
	elif atlas < 4: return Vector2i(0, atlas - 1);
	return Vector2i(floor(atlas / 4), atlas % 4);
static func create_block(x: int, y: int, type: int) -> bool:
	var coords: Vector2i = Vector2i(x, y);
	var index: int = Tiles.safe_position_to_index(x, y);
	if index < 0: return false;
	Tiles.set_on(index, type);
	Tiles.update_atlas(x, y);
	_map.set_cell(coords, type, Map.get_atlas_coords(Tiles.atlas_on(index)));
	_map.update_neigbors.call_deferred(x, y);
	Tiles.changed.emit(coords, index);
	return true;
static func destroy_block(x: int, y: int, force: float) -> bool:
	var coords: Vector2i = Vector2i(x, y);
	var index: int = Tiles.safe_position_to_index(x, y);
	if index < 0: return false;
	var result: float = Tiles.try_break(index, force);
	if result == 0:
		Tiles.set_on(index, 0);
		_map.erase_cell(coords);
		_map.update_neigbors.call_deferred(x, y);
		Tiles.changed.emit(coords, index);
		return true;
	return false;

signal loaded;

func update_neigbors(x: int, y: int) -> void:
	for yy in range(y-1, y+2):
		for xx in range(x-1, x+2):
			if xx == x && yy == y: continue;
			var index: int = Tiles.safe_position_to_index(xx, yy);
			if index < 0: continue;
			Tiles.update_atlas(xx, yy);
			set_cell(Vector2i(xx, yy), Tiles.on(index), get_atlas_coords(Tiles.atlas_at(xx, yy)));

func start() -> void:
	thread.start(generate);
func generate() -> void:
	var index: int = 0;
	var total: float = float(World.height * World.width * 1024);
	for y in range(0, World.height * 32):
		for x in range(0, World.width * 32):
			call_deferred_thread_group(
				"update_cell", x, y, 
				Tiles.on(index), Map.get_atlas_coords(Tiles.atlas_on(index)), index
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
	if id != 0: set_cell(Vector2i(x, y), id, coords);
	if index % 1024 == 1023: semaphore.post();
func prepare() -> void:
	thread.wait_to_finish();
	finish.call_deferred();
	process_mode = Node.PROCESS_MODE_INHERIT;
func finish() -> void:
	visible = true;
	Loading.finish();
	loaded.emit();
func _ready() -> void:
	_map = self;
	if World.updated: start();
	else: 
		await World.update;
		start();
