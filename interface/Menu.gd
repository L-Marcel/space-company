extends Control

const game: PackedScene = preload("res://Game.tscn");
const host_menu: PackedScene = preload("res://interface/HostMenu.tscn");

func _on_create_pressed() -> void:
	get_tree().change_scene_to_packed(host_menu);

func _on_join_pressed() -> void:
	get_tree().change_scene_to_packed(game);
	var error: Error = Client.join_game();
	if error != OK: 
		Loading.finish("Ocorreu um erro ao tentar registrar o cliente. Código: " + str(error));
