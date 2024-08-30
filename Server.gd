extends Node

signal player_connected(peer_id);
signal player_disconnected(peer_id);
signal server_disconnected;

const PORT = 7000;
const DEFAULT_SERVER_IP = "127.0.0.1";
const MAX_CONNECTIONS = 20;

var game: PackedScene = preload("res://Game.tscn");
var player_scene: PackedScene = preload("res://Player.tscn");
var players_loaded = 0;

var id: int;
var world: Node2D;

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected);
	multiplayer.peer_disconnected.connect(_on_player_disconnected);
	multiplayer.server_disconnected.connect(_on_server_disconnected);

func join_game(address = "") -> Error:
	if address.is_empty(): address = DEFAULT_SERVER_IP;
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(address, PORT);
	if error: return error;
	multiplayer.multiplayer_peer = peer;
	id = multiplayer.get_unique_id();
	return OK;
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
	Loading.start("Carregando dados do mundo . . .");
	Tiles.fetch(_seed, _bytes);
	Loading.update(5, "Carregando mundo . . .");
	id = 1;
	get_tree().change_scene_to_packed(game);
	return OK;

func exit_from_server() -> void:
	multiplayer.multiplayer_peer = null;

func _on_player_connected(id):
	if multiplayer.is_server(): 
		add_player(id);

func add_player(id: int):
	var player = player_scene.instantiate();
	player.id = id;
	player.name = str(id);
	world.add_child(player, true);
	if id != 1: World.fetch.rpc_id(id, World.width, World.height, Tiles.get_seed(), Tiles.get_bytes());
	player_connected.emit(id);

func _on_player_disconnected(id):
	player_disconnected.emit(id);
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null;
	server_disconnected.emit();
