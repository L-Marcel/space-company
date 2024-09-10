class_name BlockItem
extends Item

@export var type: int = 1;

func can_put(x: int = Cursor.x, y: int = Cursor.y) -> bool: 
	Cursor.zone.resize(8, 8, 16, 16);
	return Tiles.at(x, y) == 0 && !Cursor.zone.insiders.any(func(node: Node): return node is PhysicsBody2D);
func on_buy(x: int = Cursor.x, y: int = Cursor.y) -> void:
	Character.money -= price;
	Map.create_block(x, y, type);
