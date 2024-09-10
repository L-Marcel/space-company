class_name Item
extends Resource

@export var icon: Texture;
@export var name: String;
@export_enum("Estrutura", "Energia", "Produção") var category: String = "Estrutura";
@export var price: float = 0.0;

func can_buy() -> bool: return price <= Character.money;
func can_put(x: int = Cursor.x, y: int = Cursor.y) -> bool: return true;
func on_buy(x: int = Cursor.x, y: int = Cursor.y) -> void: pass;
