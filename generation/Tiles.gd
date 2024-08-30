extends Node

var _buffer: StreamPeerBuffer = StreamPeerBuffer.new();
var _model_buffer: StreamPeerBuffer = StreamPeerBuffer.new();
var _noise: FastNoiseLite = FastNoiseLite.new();

func _ready() -> void:
	_noise.seed = randi();
	_noise.fractal_octaves = 10;

func fetch(_seed: int, _bytes: PackedByteArray) -> void:
	_noise.seed = _seed;
	var half: int = _bytes.size() / 2;
	_buffer.data_array = _bytes.slice(0, half);
	_model_buffer.data_array = _bytes.slice(half);
func generate(_seed: int, _size: int) -> void:
	_noise.seed = _seed;
	var size: Vector2i = World.convert_size(_size);
	var index: int = 0;
	var total: float = float(1024 * size.y * size.x);
	for row in size.y:
		for column in size.x:
			for y in range(0, 32):
				for x in range(0, 32):
					var xx: int = (column * 32) + x;
					var yy: int = (row * 32) + y;
					var type: int = _get_noise_at(xx, yy);
					_buffer.resize(index);
					_buffer.seek(index);
					_buffer.put_u8(type);
					index += 1;
					Loading.update(10.0 * (index / total), "Gerando mundo . . .");
	index = 0;
	for row in size.y:
		for column in size.x:
			for y in range(0, 32):
				for x in range(0, 32):
					var xx: int = (column * 32) + x;
					var yy: int = (row * 32) + y;
					var model: int = get_model(xx, yy, size.x, size.y);
					_model_buffer.resize(index);
					_model_buffer.seek(index);
					_model_buffer.put_u8(model);
					index += 1;
					Loading.update(10.0 + (88.0 * (index / total)), "Gerando mundo . . .");

func get_model(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	var tl: int = Tiles.at(x - 1, y - 1, width, height);
	var tc: int = Tiles.at(x, y - 1, width, height);
	var tr: int = Tiles.at(x + 1, y - 1, width, height);
	var ml: int = Tiles.at(x - 1, y, width, height);
	var mr: int = Tiles.at(x + 1, y, width, height);
	var bl: int = Tiles.at(x - 1, y + 1, width, height);
	var bc: int = Tiles.at(x, y + 1, width, height);
	var br: int = Tiles.at(x + 1, y + 1, width, height);
	
	var all: Array[bool] = [
		tl != 0, tc != 0, tr != 0, ml != 0, 
		mr != 0, bl != 0, bc != 0, br != 0
	];
	
	return get_model_by(all, all);
func get_model_by(neighbors: Array[bool] = [], all: Array[bool] = []) -> int:
	var tl: bool = all[0];
	var tc: bool = all[1];
	var tr: bool = all[2];
	var ml: bool = all[3];
	var mr: bool = all[4];
	var bl: bool = all[5];
	var bc: bool = all[6];
	var br: bool = all[7];
	
	neighbors = neighbors.filter(func(value: bool): return value);
	var count: int = neighbors.size();
	match count:
		8: 
			return 38;
		7:
			if !tl: return 21;
			elif !bl: return 22;
			elif !tr: return 25;
			elif !br: return 26;
			elif !tc: return get_model_by([ml, mr, bl, bc, br], all);
			elif !ml: return get_model_by([tc, tr, mr, bc, br], all);
			elif !mr: return get_model_by([tl, tc, ml, bl, bc], all);
			else: return get_model_by([tl, tc, tr, ml, mr], all);
		1:
			if bc: return 1;
			elif tc: return 3;
			elif mr: return 7;
			elif ml: return 15;
			else: return 0;
		2:
			if tc && bc: return 2;
			elif mr && bc: return 4;
			elif tc && mr: return 6;
			elif mr && ml: return 11;
			elif ml && bc: return 12;
			elif tc && ml: return 14;
			else: return get_model_by([tc, ml, mr, bc], all);
		3, 4, 5, 6:
			if count == 6 && !tl && !br: return 28;
			elif count == 6 && !tl && !bl: return 34;
			elif count == 6 && !tl && !tr: return 36;
			elif count == 6 && !tl && !br: return 37;
			elif count == 6 && !tr && !bl: return 41;
			elif count == 6 && !bl && !br: return 42;
			elif count == 6 && !tr && !br: return 44;
			elif tc && tl && ml && mr && bc: return 16;
			elif tc && bc && mr && ml && bl: return 19;
			elif tc && bc && tr && br && mr: return 33;
			elif tc && tr && tl && ml && mr: return 39;
			elif mr && ml && bc && bl && br: return 40;
			elif tl && tc && ml && bc && bl: return 45;
			elif tc && ml && mr && bc: return 9;
			elif tc && mr && bc && br: return 17;
			elif tc && mr && bc && tr: return 18;
			elif mr && ml && bc && br: return 20;
			elif mr && ml && tc && tl: return 23;
			elif mr && ml && bc && bl: return 24;
			elif tc && tl && mr && ml: return 27;
			elif tc && ml && bl && bc: return  29;
			elif tc && tl && ml && bc: return 30;
			elif tc && bc && mr: return 5;
			elif mr && ml && bc: return 8;
			elif mr && ml && tc: return 10;
			elif ml && tc && bc: return 13;
			elif bc && mr && br: return 32;
			elif tc && tr && mr: return 35;
			elif ml && bl && bc: return 43;
			elif tl && tc && ml: return 46;
			else: return get_model_by([tc, ml, mr, bc], all);
		_: return 0;

func get_seed() -> int:
	return _noise.seeed;
func get_bytes() -> PackedByteArray:
	var bytes: PackedByteArray = [];
	bytes.append_array(_buffer.data_array);
	bytes.append_array(_model_buffer.data_array);
	return bytes;

func position_to_index(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	var column: int = clamp(floor(x / 32.0), 0, width - 1);
	var row: int = clamp(floor(y / 32.0), 0, height - 1);
	var xx: int = max(x % 32, 0);
	var yy: int = max(y % 32, 0);
	var chunk: int = (row * width) + column;
	var index: int = (chunk * 1024) + (yy * 32) + xx;
	return index;

func model_at(x: int, y: int, width: int = World.width, height: int = World.height) -> int:
	return model_on(position_to_index(x, y, width, height));
func model_on(index: int) -> int:
	_model_buffer.seek(index);
	return _model_buffer.get_u8();
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
