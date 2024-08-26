class_name Chunks
extends Node2D

func _ready() -> void:
	World.chunks = self;

func get_chunk_at(x: int, y: int) -> Chunk:
	var chunk_lines: Array[Node] = World.chunks.get_children();
	if (y < 0 || y >= chunk_lines.size()): return null;
	var chunk_line: Node = chunk_lines[y];
	if chunk_line is ChunkLine:
		var chunks: Array[Node] = chunk_line.get_children();
		if (x < 0 || x >= chunks.size()): return null;
		var chunk: Node = chunks[x];
		if chunk is Chunk: return chunk;
	return null;
