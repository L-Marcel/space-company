class_name Machine
extends Node

@export var enabled_in_editor: bool = false:
	set(value):
		enabled_in_editor = value || !Engine.is_editor_hint();
		process_mode = PROCESS_MODE_INHERIT if enabled_in_editor else PROCESS_MODE_DISABLED;
		
var looked: bool = false;
var states: Dictionary = {};

signal process_state(state_id: StringName, delta: float);
signal physics_process_state(state_id: StringName, delta: float);
signal state_entered(state_id: StringName);
signal state_exited(state_id: StringName);

func enabled() -> bool:
	return enabled_in_editor || !Engine.is_editor_hint();

func _ready() -> void:
	process_mode = PROCESS_MODE_INHERIT if enabled() else PROCESS_MODE_DISABLED;

func get_state(id: StringName) -> State:
	if states.has(id) && states[id] is State: return states[id];
	else: return null;
