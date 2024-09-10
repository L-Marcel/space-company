extends CanvasLayer

@export var progress: ProgressBar;
@export var label: Label;
@export var button: Button;

func _ready() -> void:
	visible = false;
func start(_text: String) -> void:
	progress.indeterminate = false;
	button.visible = false;
	progress.visible = true;
	progress.value = 0;
	label.text = _text;
	visible = true;
func start_indeterminate(_text: String) -> void:
	button.visible = false;
	progress.visible = true;
	progress.value = 0;
	progress.indeterminate = true;
	label.text = _text;
	visible = true;
func unsafe_update(_progress: float, _text: String, _callback: Callable = func(): return) -> void:
	progress.indeterminate = false;
	button.visible = false;
	progress.visible = true;
	progress.value = _progress;
	label.text = _text;
	_callback.call_deferred();
func update(_progress: float, _text: String, _callback: Callable = func(): return) -> void:
	unsafe_update.call_deferred(_progress, _text, _callback);
func finish(message: String = "") -> void:
	if message.is_empty():
		visible = false;
		progress.value = 0;
		label.text = "";
	else:
		progress.visible = false;
		button.visible = true;
		label.text = message;
func _on_button_pressed() -> void:
	visible = false;
	progress.visible = true;
	button.visible = false;
	label.text = "";
