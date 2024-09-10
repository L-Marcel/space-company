extends Node

var width: int = 10;
var height: int = 3;
var uuid: String;
var world: String;

var updated: bool = false;
signal update;

@rpc("authority", "call_local", "reliable")
func fetch(_name: String, _width: int, _height: int, _uuid: String, _seed: int, _bytes: PackedByteArray) -> void:
	width = _width;
	height = _height;
	uuid = _uuid;
	world = _name;
	Loading.update(0, "Carregando dados do mundo . . .");
	Tiles.fetch(_seed, _bytes);
	updated = true;
	update.emit();
func save(
	_name: String = world, 
	_uuid: String = uuid,
	_seed: int = Tiles.get_seed(), 
	_size: int = 0,
	_bytes: PackedByteArray = Tiles.get_bytes()
) -> void:
	var packed_world: StreamPeerBuffer = StreamPeerBuffer.new();
	packed_world.put_string(_name);
	packed_world.put_string(_uuid);
	packed_world.put_64(_seed);
	packed_world.put_u8(_size);
	packed_world.put_data(Tiles.get_bytes());
	packed_world.put_data(Character.to_bytes());
	var filename: String = _name.strip_escapes().trim_prefix(" ").trim_suffix(" ").to_snake_case();
	var folder: String = "user://worlds/" + filename;
	var file: FileAccess = FileAccess.open(folder + "/data.dat", FileAccess.ModeFlags.WRITE);
	if !file: return;
	file.seek(0);
	file.store_buffer(packed_world.data_array);
	file.close();

func convert_size(_size: int) -> Vector2i:
	match _size:
		0: return Vector2i(4, 5);
		1: return Vector2i(8, 10);
		3: return Vector2i(20, 40);
		_: return Vector2i(10, 20);
