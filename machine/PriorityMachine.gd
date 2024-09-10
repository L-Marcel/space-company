@tool
class_name PriorityMachine
extends Machine

signal states_changed(currents: Array[StringName]);

var current_priority: int = -1;
var current_states: Array[State] = [];

func _ready() -> void:
	super._ready();
	if enabled(): update();

func enable(state_id: StringName) -> void:
	if states.has(state_id):
		states[state_id].enabled = true;
		update();
func disable(state_id: StringName) -> void:
	if states.has(state_id):
		states[state_id].enabled = false;
		update();

func update() -> void:
	var states_array: Array[State] = [];
	for state in states:
		states_array.append(states[state]);
	var enabled_states: Array[State] = states_array.filter(func(state: State): return state.enabled);
	var valid_states: Array[State] = [];
	var _current_priority = 0;
	for state in enabled_states:
		if state.priority > _current_priority:
			valid_states.clear();
			_current_priority = state.priority;
			valid_states.append(state);
		elif state.priority == _current_priority:
			valid_states.append(state);
	var current_keys: Array[StringName] = [];
	if _current_priority != current_priority:
		_current_priority == current_priority;
		for state in current_states:
			state_exited.emit(state.id);
			state.exit();
		current_states = valid_states;
		for state in current_states:
			current_keys.append(state.id);
			state_entered.emit(state.id);
			state.enter();
	else:
		var unchanged_states: Array[State] = [];
		for state in current_states:
			if state in valid_states:
				unchanged_states.append(state);
				current_keys.append(state.id);
			else:
				state_exited.emit(state.id);
				state.exit();
		current_states = unchanged_states;
		for state in valid_states:
			if state not in current_states:
				current_keys.append(state.id);
				current_states.append(state);
				state_entered.emit(state.id);
				state.enter();
	states_changed.emit(current_keys);
