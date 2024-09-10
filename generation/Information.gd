@tool
class_name HUD
extends MarginContainer

@export var oxygen_bar: Bar;
@export var energy_bar: Bar;

func config() -> void:
	Player.current.energy_changed.connect(update_energy_bar);
	Player.current.oxygen_changed.connect(update_oxygen_bar);

func update_oxygen_bar() -> void:
	oxygen_bar.update(Player.current.oxygen);
func update_energy_bar() -> void:
	energy_bar.update(Player.current.energy);
