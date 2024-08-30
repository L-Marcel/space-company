extends Node2D

func _ready() -> void:
	Server.world = self;
	if Server.id == 1:
		Server.add_player(1);
