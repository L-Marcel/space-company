class_name Player
extends CharacterBody2D

const PROPULSION_SPEED = 60.0;
const SPEED = 100.0;

@export var sprite: AnimatedSprite2D;
@export var machine: StateMachine;
@export var input: PlayerInput;
@export var camera: Camera2D;
@export var listener: AudioListener2D;
@export var propulsion_particles: PropulsionParticles;

static var players: Array[Player] = [];
static var current: Player;

var oxygen: float = 100.0 :
	set(value):
		oxygen = value;
		if current == self:
			oxygen_changed.emit();
var energy: float = 100.0 :
	set(value):
		energy = value;
		if current == self:
			energy_changed.emit();

signal oxygen_changed;
signal energy_changed;

var flipped: bool = false :
	set(value):
		flipped = value;
		if flipped: 
			Global.flip(self);
			Global.flip(propulsion_particles);
		else: 
			Global.unflip(self);
			Global.unflip(propulsion_particles);
var need_propulsion: bool = false;
var id: int = 1:
	set(value):
		id = value;
		input.set_multiplayer_authority(id);
var username: String = "";

func move(delta: float) -> void:
	if input.jump && is_on_floor():
		need_propulsion = false;
		propulsion_particles.emitting = false;
		velocity.y = -80;
	elif is_on_floor():
		propulsion_particles.emitting = false;
		var direction: float = input.direction.x;
		if direction:
			flipped = direction < 0;
			velocity.x = move_toward(velocity.x, direction * SPEED, 1.0);
			if is_on_wall(): machine.transition("in_wall");
			else: machine.transition("walk");
		else:
			velocity.x = move_toward(velocity.x, 0, 100);
			machine.transition("idle");
	else:
		if need_propulsion:
			propulsion_particles.set_gravity(get_gravity());
			var direction: Vector2 = input.direction;
			if !direction: direction = Vector2.UP;
			propulsion_particles.set_direction(direction.rotated(deg_to_rad(180)));
			propulsion_particles.emitting = input.propulsion;
			if input.propulsion:
				velocity += direction * PROPULSION_SPEED * delta;
		else: need_propulsion = !input.propulsion;
		if velocity.x != 0:
			flipped = velocity.x < 0;
		if velocity.y <= 0:
			machine.transition("jump");
		else:
			machine.transition("fall");
		velocity += get_gravity() * delta;
func _ready() -> void:
	var is_server: bool = multiplayer.is_server();
	set_process(is_server);
	set_physics_process(is_server);
	if Client.id != id: 
		listener.queue_free();
		camera.queue_free();
	else:
		Player.current = self;
		listener.make_current();
	$Control/Label.text = str(id);
	for player in players:
		add_collision_exception_with(player);
	players.append(self);
	tree_exiting.connect(_on_tree_exiting);
	if is_server:
		World.save();

func _physics_process(delta: float) -> void:
	move_and_slide();
func _on_tree_exiting() -> void:
	players.erase(self);

func _on_idle_entered() -> void:
	sprite.play("idle");
func _on_walk_entered() -> void:
	sprite.play("walk");
func _on_in_wall_entered() -> void:
	sprite.play("in_wall");
	Cursor.enable_destroy(floor((global_position.x + (-7 if flipped else 7))/ 16), floor(global_position.y / 16) - 1);
func _on_in_wall_exited() -> void:
	Cursor.disable_destroy();
func _on_jump_entered() -> void:
	sprite.play("jump");
func _on_fall_entered() -> void:
	sprite.play("fall");

func _on_idle_process(delta: float) -> void:
	move(delta);
func _on_walk_process(delta: float) -> void:
	move(delta);
func _on_in_wall_process(delta: float) -> void:
	move(delta);
	if is_on_wall() && is_on_floor() && input.action:
		destroy_wall_block(delta);
func _on_jump_process(delta: float) -> void:
	move(delta);
func _on_fall_process(delta: float) -> void:
	move(delta);

func destroy_wall_block(delta: float) -> void:
	destroy_block.rpc(Cursor.x, Cursor.y, delta);

@rpc("any_peer", "call_local", "reliable")
func destroy_block(x: int, y: int, delta: float) -> void:
	Map.destroy_block(x, y, delta);
