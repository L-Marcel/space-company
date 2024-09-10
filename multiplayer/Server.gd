extends Node

signal player_connected(peer_id);
signal player_disconnected(peer_id);
signal server_disconnected;

const DEFAULT_IP = "127.0.0.1";
const PORT = 7000;
const MAX_CONNECTIONS = 20;

const menu: PackedScene = preload("res://interface/Menu.tscn");
const game: PackedScene = preload("res://Game.tscn");

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected);
	multiplayer.peer_disconnected.connect(_on_peer_disconnected);
	multiplayer.server_disconnected.connect(_on_server_disconnected);
	multiplayer.connection_failed.connect(_on_connection_failed);

@rpc("any_peer", "call_local", "reliable")
func request_access(keys: PackedStringArray) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id();
	for key in keys:
		var parts = key.split("___", false, 2);
		if parts.size() != 3: continue;
		var uuid: String = parts[0];
		var seed: String = parts[1];
		var username: String = parts[2];
		if uuid == World.uuid && seed == str(Tiles.get_seed()) && Character.exists(username):
			Client.registry.rpc_id(sender_id, username, key);
			return;
	RegistryScreen.request.rpc_id(sender_id);

@rpc("any_peer", "call_local", "reliable")
func registry(username: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id();
	if Character.exists(username):
		RegistryScreen.error.rpc_id(sender_id, ERR_ALREADY_EXISTS);
		return;
	Character.add(username);
	Client.registry.rpc_id(sender_id, username, World.uuid + "___" + str(Tiles.get_seed()) + "___" + str(username));

func create_game(
	_name: String,
	_uuid: String,
	_size: int,
	_seed: int,
	_bytes: PackedByteArray
) -> Error:
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_server(PORT, MAX_CONNECTIONS);
	if error != OK: return error;
	multiplayer.multiplayer_peer = peer;
	var size: Vector2i = World.convert_size(_size);
	World.width = size.x;
	World.height = size.y;
	World.uuid = _uuid;
	World.world = _name;
	get_tree().change_scene_to_packed(game);
	Loading.start("Carregando dados do mundo . . .");
	Client.id = 1;
	_bytes = Tiles.fetch(_seed, _bytes);
	Character.from_bytes(_bytes);
	World.updated = true;
	World.update.emit();
	return OK;

func _on_peer_connected(id):
	if multiplayer.is_server(): 
		World.fetch.rpc_id(id, World.world, World.width, World.height, World.uuid, Tiles.get_seed(), Tiles.get_bytes());
func _on_peer_disconnected(id):
	if multiplayer.is_server():
		pass;
	player_disconnected.emit(id);
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null;
	server_disconnected.emit();
func _on_connection_failed():
	get_tree().change_scene_to_packed(menu);
	Loading.finish("Não foi possível se conectar ao servidor! Verifique os dados informados, sua conexão com a internet e a disponibilidade do servidor.");
