class_name Zone
extends Area2D

@export var collision: CollisionShape2D;
var insiders: Array[Node2D] = [];

func resize(x: float, y: float, w: float, h: float) -> void:
	collision.position.x = x;
	collision.position.y = y;
	(collision.shape as RectangleShape2D).size = Vector2(w, h);
	
func _on_body_entered(body: Node2D) -> void:
	insiders.append(body);
func _on_body_exited(body: Node2D) -> void:
	insiders.erase(body);
