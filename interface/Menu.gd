extends Control

const host_menu: PackedScene = preload("res://interface/HostMenu.tscn");

func _on_create_pressed() -> void:
	get_tree().change_scene_to_packed(host_menu);
