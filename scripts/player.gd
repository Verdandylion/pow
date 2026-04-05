extends CharacterBody3D
## player.gd — first-person controller
## Place this script on the root CharacterBody3D node in scenes/player.tscn

# ── Movement tuning ────────────────────────────────────────────────────────
const WALK_SPEED  : float = 5.0   # metres per second (realistic adult walk)
const JUMP_SPEED  : float = 5.0   # upward velocity on jump
const GRAVITY     : float = 12.0  # stronger than real for snappier feel

# ── Mouse-look tuning ──────────────────────────────────────────────────────
const MOUSE_SENS  : float = 0.002  # radians per pixel of mouse movement

# ── Interaction ────────────────────────────────────────────────────────────
# Reach is set on the InteractionRay node's target_position in player.tscn (3 m)

# ── Node references (resolved at runtime) ─────────────────────────────────
@onready var head : Node3D    = $Head
@onready var ray  : RayCast3D = $Head/InteractionRay


func _ready() -> void:
	# Capture mouse so it controls the camera instead of the OS cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	# ── Mouse look ──────────────────────────────────────────────────────────
	if event is InputEventMouseMotion:
		# Rotate the entire body left/right (yaw) with the mouse X axis
		rotate_y(-event.relative.x * MOUSE_SENS)
		# Rotate only the head up/down (pitch) with the mouse Y axis
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		# Clamp vertical look so the player can't flip upside-down
		head.rotation.x = clamp(head.rotation.x,
				deg_to_rad(-85.0), deg_to_rad(85.0))

	# ── Toggle mouse capture with Escape ────────────────────────────────────
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# ── Interaction: press E to interact with nearby objects ─────────────────
	if event.is_action_pressed("interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	# ── Apply gravity when airborne ─────────────────────────────────────────
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# ── Jump ────────────────────────────────────────────────────────────────
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED

	# ── Build a horizontal movement direction from WASD ──────────────────────
	# get_axis returns -1 to +1 based on which action is held
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),   # A = -1, D = +1
		Input.get_axis("move_forward", "move_back")  # W = -1, S = +1
	)

	# Convert 2-D input into a 3-D direction aligned with where we face
	var move_dir := (
		transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	# Apply horizontal speed (vertical is handled by gravity / jump above)
	velocity.x = move_dir.x * WALK_SPEED
	velocity.z = move_dir.z * WALK_SPEED

	# Move the character, handling sliding against walls automatically
	move_and_slide()


## Called when the player presses E.
## Fires the InteractionRay; if it hits an object that has an "interact"
## method we call it.
func _try_interact() -> void:
	if ray.is_colliding():
		var hit := ray.get_collider()
		if hit.has_method("interact"):
			hit.interact()
