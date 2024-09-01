extends Node

var width: int = 10;
var height: int = 3;

@rpc("authority", "call_local", "reliable")
func fetch(_width: int, _height: int, _seed: int, _bytes: PackedByteArray) -> void:
	width = _width;
	height = _height;
	Loading.update(0, "Carregando dados do mundo . . .");
	Tiles.fetch(_seed, _bytes);
func convert_size(_size: int) -> Vector2i:
	match _size:
		0: return Vector2i(4, 5);
		1: return Vector2i(8, 10);
		3: return Vector2i(20, 40);
		_: return Vector2i(10, 20);
