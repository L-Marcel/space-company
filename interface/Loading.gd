extends CanvasLayer

@export var progress: ProgressBar;
@export var label: Label;

func _ready() -> void:
	visible = false;
func start(_text: String) -> void:
	progress.value = 0;
	label.text = _text;
	visible = true;
func unsafe_update(_progress: float, _text: String, _callback: Callable = func(): return) -> void:
	progress.value = _progress;
	label.text = _text;
	_callback.call_deferred();
func update(_progress: float, _text: String, _callback: Callable = func(): return) -> void:
	unsafe_update.call_deferred(_progress, _text, _callback);
func finish() -> void:
	visible = false;
	progress.value = 0;
	label.text = "";
