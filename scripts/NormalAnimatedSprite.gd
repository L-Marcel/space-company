@tool
class_name NormalAnimatedSprite
extends AnimatedSprite2D

@export var spritesheet: Texture2D;
@export var normal_spritesheet: Texture2D;
@export var box: Vector2i = Vector2i(16, 16);
@export var gap: Vector2i;
@export var animations: Array[NormalAnimation] = [];

func _ready() -> void:
	if Engine.is_editor_hint():
		sprite_frames.clear_all();
		var gap_y: int = 0;
		var index: int = 0;
		for _animation in animations:
			var gap_x: int = 0;
			sprite_frames.add_animation(_animation.id);
			sprite_frames.set_animation_loop(_animation.id, _animation.loop);
			sprite_frames.set_animation_speed(_animation.id, _animation.fps);
			for _frame in range(0, _animation.frames):
				var frame_texture: CanvasTexture = CanvasTexture.new();
				var region: Rect2i = Rect2i((_frame * box.x) + gap_x, (index * box.y) + gap_y, box.x, box.y);
				var diffuse_frame_texture: ImageTexture = ImageTexture.create_from_image(
					spritesheet.get_image().get_region(region)	
				);
				var normal_frame_texture: ImageTexture = ImageTexture.create_from_image(
					normal_spritesheet.get_image().get_region(region)	
				);
				frame_texture.diffuse_texture = diffuse_frame_texture;
				frame_texture.normal_texture = normal_frame_texture;
				sprite_frames.add_frame(_animation.id, frame_texture);
				gap_x += gap.x;
			gap_y += gap.y;
			index += 1;
		sprite_frames.remove_animation("default");
