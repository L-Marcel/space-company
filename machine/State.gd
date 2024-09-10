@icon("../assets/icons/icon_state.png")
@tool
class_name State
extends Node

@export var id: StringName = "" :
	set(value):
		if get_parent() is Machine:
			if get_parent().states.has(id):
				get_parent().states.erase(id);
			if get_parent() is StateMachine && get_parent().initial == id: get_parent().initial = value;
			id = value;
			get_parent().states[id] = self;
			get_parent().update_configuration_warnings();
		update_configuration_warnings();
@export var priority: int = 0;
@export var enabled: bool = false :
	set(value):
		enabled = value;

signal process(delta: float);
signal physics_process(delta: float);
signal entered();
signal exited();

func enter() -> void:
	entered.emit();
	process_mode = PROCESS_MODE_INHERIT;
func exit() -> void:
	process_mode = PROCESS_MODE_DISABLED;
	exited.emit();

func _enter_tree() -> void:
	if !renamed.is_connected(_renamed):
		renamed.connect(_renamed);
func _ready() -> void:
	_renamed();
func _exit_tree() -> void:
	if get_parent() is Machine:
		if get_parent() is StateMachine && get_parent().initial == id: get_parent().initial = "";
		get_parent().states.erase(id);
		get_parent().update_configuration_warnings();
	update_configuration_warnings();
func _process(delta: float) -> void:
	if get_parent() is Machine: 
		get_parent().looked = false;
		get_parent().process_state.emit(id, delta);
	process.emit(delta);
func _physics_process(delta: float) -> void:
	if get_parent() is Machine: get_parent().physics_process_state.emit(id, delta);
	physics_process.emit(delta);
func _get_configuration_warnings() -> PackedStringArray:
	var errors: PackedStringArray = [];
	if get_parent() is not Machine:
		errors.append("The parent should be a 'Machine'!");
	return errors;
func _renamed() -> void:
	id = name.to_snake_case();
