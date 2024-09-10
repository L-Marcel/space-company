@tool
extends Control

@export var builder: Control;
@export var shop: CanvasLayer;
@export var information: Control;
@export var list: ItemList;
@export var item_icon: TextureRect;

@export var items: Array[Item] = [] :
	set(value):
		items = value;
		update_shop_list();

var building: bool = true;
var item: Item;

func update_screen_size() -> void:
	if size != information.size && size != Vector2.ZERO:
		information.size /= information.scale;
	information.position = Vector2.ZERO;
func update_shop_list() -> void:
	if list:
		list.clear();
		for _item in items:
			list.add_item(
				_item.name,
				_item.icon,
				true
			);
		list.select(0);
		_on_item_list_item_clicked(0, Vector2.ZERO, 0);

func _ready() -> void:
	update_shop_list();
	update_screen_size();
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return;
	if Input.is_action_just_pressed("switch_builder"):
		builder.visible = !builder.visible;
		shop.visible = builder.visible;
		if builder.visible: Cursor.enable_put();
		else: Cursor.disable_put();
	if builder.visible && item:
		item_icon.visible = true;
		item_icon.position = Cursor.position;
		item_icon.texture = item.icon;
		if item.can_buy() && item.can_put():
			item_icon.modulate = Color.hex(0xffffff80);
			if Input.is_action_pressed("action"):
				item.on_buy();
		else:
			item_icon.modulate = Color.hex(0xff000080);
	else:
		item_icon.visible = false;
func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var item_index: int = 0;
	for _item in items:
		if item_index == index: 
			item = _item;
			break;
		index += 1;
func _on_resized() -> void:
	update_screen_size();
