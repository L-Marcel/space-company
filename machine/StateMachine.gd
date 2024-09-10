@icon("../assets/icons/icon_state_machine.png")
@tool
class_name StateMachine
extends Machine

@export var initial: StringName :
	set(value):
		initial = value;
		update_configuration_warnings();

var previous: StringName;
var current: StringName;

func _ready() -> void:
	super._ready();
	for child in get_children(): child.process_mode = PROCESS_MODE_DISABLED;
	if enabled(): transition(initial);

func get_state(id: StringName = current) -> State:
	return super.get_state(id);
func transition_with_delay(delay: float, to: StringName, look: bool = true) -> void:
	if is_inside_tree():
		await get_tree().create_timer(delay).timeout;
	transition(to, look);
func transition(to: StringName, look: bool = true) -> void:
	if looked || current == to: return;
	if look: looked = true;
	if current:
		var current_state: State = get_state();
		if current_state:
			state_exited.emit(current_state.id);
			current_state.exit();
		previous = StringName(current);
	else: previous = StringName(initial);
	current = StringName(to);
	if current:
		var current_state: State = get_state();
		if current_state:
			state_entered.emit(current_state.id);
			current_state.enter();
func transition_back_with_delay(delay: float, look: bool = true) -> void:
	transition_with_delay(delay, previous, look);
func transition_back(look: bool = true) -> void:
	transition(previous, look);

func _get_configuration_warnings() -> PackedStringArray:
	var errors: PackedStringArray = [];
	if initial.is_empty():
		errors.append("The 'initial' property should be set!");
	if get_child_count() == 0:
		errors.append("There should be one or more 'State' nodes as children!");
	for child in get_children():
		if child is not State:
			errors.append("Only 'State' nodes should be children!");
	return errors;
