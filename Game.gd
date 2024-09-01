class_name Game
extends Node2D

var player_scene: PackedScene = preload("res://Player.tscn");

func _on_map_loaded() -> void:
	add_player.rpc_id(1, Client.id);

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int) -> void:
	var player = player_scene.instantiate();
	player.id = id;
	player.name = str(id);
	add_child(player, true);
	Server.player_connected.emit(id);
