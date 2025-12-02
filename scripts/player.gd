extends CharacterBody3D

# Movement settings
@export var walk_speed = 5.0
@export var sprint_speed = 8.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

# Stamina settings
@export var max_stamina = 100.0
@export var stamina_drain_rate = 20.0
@export var stamina_regen_rate = 15.0

# State
var stamina = max_stamina
var is_sprinting = false
var flashlight_on = true
var is_hiding = false

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Node references
@onready var camera = $Camera3D
@onready var flashlight = $Camera3D/SpotLight3D

func _ready():
	# Capture mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Initialize flashlight state
	if flashlight:
		flashlight.visible = true

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion and not is_hiding:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	# Toggle flashlight
	if event.is_action_pressed("flashlight") and not is_hiding:
		toggle_flashlight()

	# Release mouse with ESC
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if is_hiding:
		return

	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# DEBUG: Print status
	if Engine.get_physics_frames() % 60 == 0:  # Print once per second
		print("On floor: ", is_on_floor(), " | Position: ", global_position, " | Velocity: ", velocity)

	# Handle sprint and stamina
	is_sprinting = Input.is_action_pressed("sprint") and stamina > 0

	if is_sprinting:
		stamina -= stamina_drain_rate * delta
		stamina = max(0, stamina)
	else:
		stamina += stamina_regen_rate * delta
		stamina = min(max_stamina, stamina)

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# DEBUG: Print input
	if input_dir.length() > 0 and Engine.get_physics_frames() % 30 == 0:
		print("Input: ", input_dir, " | Direction: ", direction)

	# Apply movement
	if direction:
		var current_speed = sprint_speed if is_sprinting else walk_speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()

func toggle_flashlight():
	flashlight_on = !flashlight_on
	if flashlight:
		flashlight.visible = flashlight_on

func set_hiding(hiding: bool):
	is_hiding = hiding
	if hiding:
		# Turn off flashlight when hiding
		if flashlight_on:
			toggle_flashlight()

func is_player_hiding() -> bool:
	return is_hiding

func get_stamina_percent() -> float:
	return stamina / max_stamina
