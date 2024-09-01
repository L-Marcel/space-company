extends Node

var game: PackedScene = preload("res://Game.tscn");
var id: int = 0;

func _ready() -> void:
	randomize();

func join_game(address = "") -> Error:
	Loading.start("Procurando servidor . . .");
	if address.is_empty(): address = Server.DEFAULT_IP;
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(address, Server.PORT);
	if error:
		Loading.finish(); 
		return error;
	get_tree().change_scene_to_packed(game);
	Loading.update(0, "Conectando-se ao servidor . . .");
	multiplayer.multiplayer_peer = peer;
	id = multiplayer.get_unique_id();
	return OK;
func exit_from_server() -> void:
	multiplayer.multiplayer_peer = null;
