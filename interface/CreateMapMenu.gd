extends Control

var host_menu: PackedScene = preload("res://interface/HostMenu.tscn");

@export var seed_box: SpinBox;
@export var error_label: Label;

var world_size: int = 2;
var world_name: String = "";
var world_seed: int = randi();
var thread: Thread = Thread.new();

func _ready() -> void:
	seed_box.value = world_seed;
func _on_option_button_item_selected(index: int) -> void:
	world_size = index;
func _on_spin_box_value_changed(value: float) -> void:
	world_seed = int(value);
func _on_line_edit_text_changed(new_text: String) -> void:
	world_name = new_text;
func _on_new_pressed() -> void:
	if world_name.is_empty():
		error_label.text = "O nome do mundo deve ser informado!";
	else:
		Loading.start("Gerando mundo . . .");
		thread.start(generate.bind(world_seed, world_size, world_name));
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_packed(host_menu);

func generate(_seed: int, _size: int, _name: String) -> void:
	var filename: String = _name.strip_escapes().trim_prefix(" ").trim_suffix(" ").to_snake_case();
	var folder: String = "user://worlds/" + filename;
	if !DirAccess.dir_exists_absolute(folder): 
		var error: Error = DirAccess.make_dir_absolute(folder);
		if error != OK: 
			finish.call_deferred(error);
			return;
	elif FileAccess.file_exists(folder + "/data.dat"): 
		finish.call_deferred(ERR_ALREADY_EXISTS);
		return;
	Tiles.generate(_seed, _size);
	Loading.update(98, "Salvando arquivo . . .");
	World.save(_name, MinosUUIDGenerator.generate_new_UUID(), _seed, _size);
	Loading.update(100, "Concluindo . . .");
	finish.call_deferred(OK);
func finish(error: int) -> void:
	thread.wait_to_finish();
	if error == OK:
		get_tree().change_scene_to_packed(host_menu);
	else:
		match error:
			ERR_ALREADY_EXISTS: error_label.text = "Esse nome já está em uso!";
			ERR_FILE_CANT_OPEN: error_label.text = "Não foi possível abrir/criar o arquivo!";
			_: error_label.text = "Ocorreu um erro desconhecido!";
	Loading.finish();
