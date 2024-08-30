@tool
class_name MapItem
extends Control

var delete_confirmation_scene: PackedScene = preload("res://interface/DeleteWorldConfirmation.tscn");

@export var _name_label: Label;
@export var _seed_label: Label;
@export var _size_label: Label;

var world_name: String = "Exemplo";
var world_folder: String = "";
var world_seed: int = 1000000;
var world_size: int;
var world_data: PackedByteArray = [];

func _ready() -> void:
	_name_label.text = world_name;
	_seed_label.text = "Semente: " + str(world_seed);
	match world_size:
		0: _size_label.text = "Muito pequeno";
		1: _size_label.text = "Pequeno";
		2: _size_label.text = "Médio";
		3: _size_label.text = "Grande";
	%Load.custom_minimum_size = %Container.size;
	%Container.update_minimum_size();
	
func _on_container_resized() -> void:
	%Load.custom_minimum_size = %Container.size;

func _on_delete_pressed() -> void:
	var confirmation: ConfirmationDialog = delete_confirmation_scene.instantiate();
	confirmation.confirmed.connect(_on_confirm_delete);
	get_tree().root.add_child(confirmation);

func _on_confirm_delete() -> void:
	if DirAccess.dir_exists_absolute(world_folder):
		var error: Error = OS.move_to_trash(ProjectSettings.globalize_path(world_folder));
		if error == OK:
			queue_free();

func _on_load_pressed() -> void:
	Server.create_game(world_name, world_size, world_size, world_data);
