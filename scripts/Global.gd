extends Node

func flip(node: Node2D) -> void:
	node.scale.y = -abs(node.scale.y);
	node.rotation_degrees = 180;
func unflip(node: Node2D) -> void:
	node.scale.y = abs(node.scale.y);
	node.rotation_degrees = 0;
