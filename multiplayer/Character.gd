class_name Character
extends Resource

static var money: float = 0;
static var characters: Dictionary = {};
static func add(_username: String):
	characters[_username] = Character.new(_username);
static func find(_username: String) -> Character:
	if characters.has(_username):
		return characters[_username];
	return null;
static func exists(_username: String) -> bool:
	return characters.has(_username);

func _init(_username: String) -> void:
	username = _username;

var username: String = "";
var energy: float = 100.0;
var oxigen: float = 100.0;
var spawn: int = 0;

static func from_bytes(bytes: PackedByteArray) -> void:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new();
	buffer.data_array = bytes;
	var index: int = 0;

	while(index < buffer.get_size() - 1):
		buffer.seek(index);
		var _username_size: int = buffer.get_u32();
		index += 4;
		buffer.seek(index);
		var _username: String = buffer.get_string(_username_size);
		index += _username_size;
		Character.add(_username);
		var _spawn: int = buffer.get_u8();
		index += 1;
		characters[_username].spawn = _spawn;
	
static func to_bytes() -> PackedByteArray:
	var bytes: PackedByteArray = [];
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new();
	for character in characters:
		buffer.put_string(characters[character].username);
		buffer.put_u8(characters[character].spawn);
	return buffer.data_array;
