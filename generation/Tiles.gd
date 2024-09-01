extends Node

var _buffer: StreamPeerBuffer = StreamPeerBuffer.new();
var _atlas_buffer: StreamPeerBuffer = StreamPeerBuffer.new();
var _noise: FastNoiseLite = FastNoiseLite.new();

var updated: bool = false;
signal update;

func _ready() -> void:
	_noise.seed = randi();
	_noise.fractal_octaves = 10;

func fetch(_seed: int, _bytes: PackedByteArray) -> void:
	_noise.seed = _seed;
	var half: int = floor(_bytes.size() / 2);
	_buffer.data_array = _bytes.slice(0, half);
	_atlas_buffer.data_array = _bytes.slice(half);
	Loading.update(5, "Carregando mundo . . .");
	updated = true;
	update.emit();
func generate(_seed: int, _size: int) -> void:
	_noise.seed = _seed;
	var size: Vector2i = World.convert_size(_size);
	var index: int = 0;
	var total: float = float(1024 * size.y * size.x);
	for y in size.y * 32:
		for x in size.x * 32:
			var type: int = _get_noise_at(x, y);
			_buffer.resize(index);
			_buffer.seek(index);
			_buffer.put_u8(type);
			index += 1;
		Loading.update(38.0 * (index / total), "Gerando mundo . . .");
		OS.delay_msec(1);
	index = 0;
	for y in size.y * 32:
		for x in size.x * 32:
			var atlas: int = get_atlas(x, y, size.x, size.y);
			_atlas_buffer.resize(index);
			_atlas_buffer.seek(index);
			_atlas_buffer.put_u8(atlas);
			index += 1;
			Loading.update(38.0 + (70.0 * (index / total)), "Gerando mundo . . .");

func get_atlas(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	var tl: int = Tiles.at(x - 1, y - 1, width, height);
	var tc: int = Tiles.at(x, y - 1, width, height);
	var tr: int = Tiles.at(x + 1, y - 1, width, height);
	var ml: int = Tiles.at(x - 1, y, width, height);
	var mr: int = Tiles.at(x + 1, y, width, height);
	var bl: int = Tiles.at(x - 1, y + 1, width, height);
	var bc: int = Tiles.at(x, y + 1, width, height);
	var br: int = Tiles.at(x + 1, y + 1, width, height);
	
	return match_atlas([
		tl != 0, tc != 0, tr != 0, ml != 0, 
		mr != 0, bl != 0, bc != 0, br != 0
	]);
func match_atlas(neighborts: Array[bool] = []) -> int:
	match neighborts:
		#8
		[true, true, true, true, true, true, true, true]: return 38;
		#7
		[false, true, true, true, true, true, true, true]: return 21;
		[true, true, false, true, true, true, true, true]: return 25;
		[true, true, true, true, true, false, true, true]: return 22;
		[true, true, true, true, true, true, true, false]: return 26;
		#6
		[false, true, false, true, true, true, true, true]: return 36;
		[false, true, true, true, true, false, true, true]: return 34;
		[true, true, true, true, true, false, true, false]: return 43;
		[true, true, false, true, true, true, true, false]: return 45;
		[false, true, true, true, true, true, true, false]: return 37;
		[true, true, false, true, true, false, true, true]: return 42;
		#5
		[true, true, false, true, true, false, true, false]: return 16;
		[false, true, false, true, true, true, true, false]: return 18;
		[false, true, true, true, true, false, true, false]: return 28;
		[false, true, false, true, true, false, true, true]: return 31;
		[_, false, _, true, true, true, true, true]: return 40;
		[_, true, true, false, true, _, true, true]: return 33;
		[true, true, true, true, true, _, false, _]: return 39;
		[true, true, _, true, false, true, true, _]: return 46;
		#4
		[false, true, false, true, true, false, true, false]: return 9;
		[_, false, _, true, true, false, true, true]: return 20;
		[_, false, _, true, true, true, true, false]: return 24;
		[_, true, false, false, true, _, true, true]: return 17;
		[_, true, true, false, true, _, true, false]: return 18;
		[false, true, _, true, false, true, true, _]: return 29;
		[true, true, _, true, false, false, true, _]: return 30;
		[false, true, true, true, true, _, false, _]: return 23;
		[true, true, false, true, true, _, false, _]: return 27;
		#3
		[_, false, _, true, true, false, true, false]: return 8;
		[_, true, false, false, true, _, true, false]: return 5;
		[false, true, _, true, false, false, true, _]: return 13;
		[false, true, false, true, true, _, false, _]: return 10;
		[_, false, _, false, true, _, true, true]: return 32;
		[_, false, _, true, false, true, true, _]: return 44;
		[_, true, true, false, true, _, false, _]: return 35;
		[true, true, _, true, false, _, false, _]: return 47;
		#2
		[_, false, _, false, true, _, true, false]: return 4;
		[_, false, _, true, false, false, true, _]: return 12;
		[_, true, false, false, true, _, false, _]: return 6;
		[false, true, _, true, false, _, false, _]: return 14;
		[_, true, _, false, false, _, true, _]: return 2;
		[_, false, _, true, true, _, false, _]: return 11;
		#1
		[_, false, _, false, false, _, true, _]: return 1;
		[_, true, _, false, false, _, false, _]: return 3;
		[_, false, _, false, true, _, false, _]: return 7;
		[_, false, _, true, false, _, false, _]: return 15;
		#0
		[_, false, _, false, false, _, false, _]: return 0;
		_: return 41;

func get_seed() -> int:
	return _noise.seeed;
func get_bytes() -> PackedByteArray:
	var bytes: PackedByteArray = [];
	bytes.append_array(_buffer.data_array);
	bytes.append_array(_atlas_buffer.data_array);
	return bytes;

func position_to_index(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	var xx: int = width * 32;
	var yy: int = height * 32;
	return (clamp(y, 0, yy - 1) * xx) + clamp(x, 0, xx - 1);
func atlas_at(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	return atlas_on(position_to_index(x, y, width, height));
func atlas_on(index: int) -> int:
	_atlas_buffer.seek(index);
	return _atlas_buffer.get_u8();
func at(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	return on(position_to_index(x, y, width, height));
func on(index: int) -> int:
	_buffer.seek(index);
	return _buffer.get_u8();

func _get_noise_at(x: int, y: int) -> int:
	var surface: float = (_noise.get_noise_2d(x, 0) * 10) + 10;
	var value: float = _noise.get_noise_2d(x, y);
	if y < surface: return 0;
	elif value >= 0.5: return 3;
	elif value >= -0.5: return 2;
	return 0;
