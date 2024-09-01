extends Node

signal player_connected(peer_id);
signal player_disconnected(peer_id);
signal server_disconnected;

const DEFAULT_IP = "127.0.0.1";
const PORT = 7000;
const MAX_CONNECTIONS = 20;

var game: PackedScene = preload("res://Game.tscn");

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected);
	multiplayer.peer_disconnected.connect(_on_peer_disconnected);
	multiplayer.server_disconnected.connect(_on_server_disconnected);

func create_game(
	_name: String,
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
	get_tree().change_scene_to_packed(game);
	Loading.start("Carregando dados do mundo . . .");
	Client.id = 1;
	Tiles.fetch(_seed, _bytes);
	return OK;

func _on_peer_connected(id):
	if multiplayer.is_server(): 
		World.fetch.rpc_id(id, World.width, World.height, Tiles.get_seed(), Tiles.get_bytes());
func _on_peer_disconnected(id):
	if multiplayer.is_server():
		pass;
	player_disconnected.emit(id);
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null;
	server_disconnected.emit();
