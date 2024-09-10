class_name PropulsionParticles
extends GPUParticles2D

func set_gravity(gravity: Vector2) -> void:
	(process_material as ParticleProcessMaterial).gravity.y = gravity.y / 10.0;
	(process_material as ParticleProcessMaterial).gravity.x = gravity.x / 10.0;

func set_direction(direction: Vector2) -> void:
	(process_material as ParticleProcessMaterial).direction.x = direction.x;
	(process_material as ParticleProcessMaterial).direction.y = direction.y;
