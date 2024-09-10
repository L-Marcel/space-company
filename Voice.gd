class_name Voice
extends Node2D

@export var input: AudioStreamPlayer2D;
@export var output: AudioStreamPlayer2D;
var bus_index: int = 0;
var effect: AudioEffect;

func _ready() -> void:
	input.stream = AudioStreamMicrophone.new();
	input.play();
	output.play();
	bus_index = AudioServer.get_bus_index("Record");
	effect = AudioServer.get_bus_effect(bus_index, 2);

func _process(delta: float) -> void:
	if effect.can_get_buffer(512) && output.get_stream_playback().can_push_buffer(512):
		send_data.rpc(effect.get_buffer(512));
	effect.clear_buffer();

@rpc("any_peer", "call_remote", "reliable")
func send_data(data: PackedVector2Array):
	for i in range(0, 512):
		output.get_stream_playback().push_frame(data[i]);
