class_name Game
extends Node2D

var player_scene: PackedScene = preload("res://Player.tscn");

func _on_map_loaded() -> void:
	RegistryScreen.request_to_server();
	if !RegistryScreen.is_finished:
		await RegistryScreen.finished;
	add_player.rpc_id(1, Client.id, Client.username);
func _ready() -> void:
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY,
		80
	);

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, username: String) -> void:
	var player = player_scene.instantiate();
	player.id = id;
	player.name = username;
	player.username = username;
	player.position.x = World.width * 256;
	add_child(player, true);
	Server.player_connected.emit(id);
