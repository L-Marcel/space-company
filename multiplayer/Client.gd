extends Node

var id: int = 0;
var username: String = "";

func _ready() -> void:
	randomize();

@rpc("any_peer", "call_local", "reliable")
func registry(_username: String, _access_key: String) -> void:
	username = _username;
	RegistryScreen.finish(_access_key);

func join_game(address: String = "") -> Error:
	Loading.start_indeterminate("Procurando servidor . . .");
	if address.is_empty(): address = Server.DEFAULT_IP;
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(address, Server.PORT);
	if error != OK: return error;
	multiplayer.multiplayer_peer = peer;
	id = multiplayer.get_unique_id();
	return OK;
func exit_from_server() -> void:
	multiplayer.multiplayer_peer = null;
