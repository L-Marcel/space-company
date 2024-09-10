extends CanvasLayer

var host_menu: PackedScene = preload("res://interface/HostMenu.tscn");

@export var error_label: Label;

var is_finished: bool = false;
signal finished;

var username: String = "";

func _ready() -> void:
	if !DirAccess.dir_exists_absolute("user://access_keys/"): 
		var error: Error = DirAccess.make_dir_absolute("user://access_keys/");
		if error != OK: return;

func request_to_server() -> void:
	var maps_name: PackedStringArray = DirAccess.get_files_at("user://access_keys/");
	Server.request_access.rpc_id(1, maps_name);

@rpc("any_peer", "call_local", "unreliable")
func request() -> void:
	visible = true;
func finish(access_key: String) -> void:
	visible = false;
	var file: FileAccess = FileAccess.open("user://access_keys/" + str(access_key), FileAccess.ModeFlags.WRITE);
	file.close();
	is_finished = true;
	finished.emit();

@rpc("any_peer", "call_local", "reliable")
func error(err: Error) -> void:
	match err:
		ERR_ALREADY_EXISTS: error_label.text = "Nome em uso!";
		_: error_label.text = "Erro desconhecido!";

func _on_line_edit_text_changed(new_text: String) -> void:
	username = new_text;
func _on_new_pressed() -> void:
	Server.registry.rpc_id(1, username);
func _on_exit_pressed() -> void:
	Client.exit_from_server();
