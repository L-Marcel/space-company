extends Control

var create_map: PackedScene = load("res://interface/CreateMapMenu.tscn");
var menu: PackedScene = load("res://interface/Menu.tscn");
var map_item_scene: PackedScene = load("res://interface/MapItem.tscn");

@export var maps_container: VBoxContainer;

func _ready() -> void:
	if !DirAccess.dir_exists_absolute("user://worlds/"): 
		var error: Error = DirAccess.make_dir_absolute("user://worlds/");
		if error != OK: return;
	var maps_name: PackedStringArray = DirAccess.get_directories_at("user://worlds/");
	for map in maps_name:
		var folder: String = "user://worlds/" + map;
		var path: String = folder + "/data.dat";
		var data: PackedByteArray = FileAccess.get_file_as_bytes(path);
		if !data.is_empty():
			var buffer: StreamPeerBuffer = StreamPeerBuffer.new();
			buffer.data_array = data;
			buffer.seek(0)
			var _name_size: int = buffer.get_u32();
			buffer.seek(4);
			var _name: String = buffer.get_string(_name_size);
			buffer.seek(4 + _name_size);
			var _seed: int = buffer.get_64();
			buffer.seek(12 + _name_size);
			var _size: int = buffer.get_u8();
			buffer.seek(13 + _name_size);
			var _data: PackedByteArray = data.slice(13 + _name_size);
			var map_item: MapItem = map_item_scene.instantiate();
			map_item.world_name = _name;
			map_item.world_seed = _seed;
			map_item.world_size = _size;
			map_item.world_data = _data;
			map_item.world_folder = folder;
			maps_container.add_child(map_item);

func _on_new_pressed() -> void:
	get_tree().change_scene_to_packed(create_map);

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_packed(menu);
