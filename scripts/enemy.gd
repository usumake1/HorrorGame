extends CharacterBody3D

enum State { PATROL, CHASE, SEARCH }

# Movement settings
@export var patrol_speed = 2.0
@export var chase_speed = 5.0
@export var rotation_speed = 5.0

# Detection settings
@export var vision_range = 15.0
@export var vision_angle = 60.0  # Half angle in degrees

# Search settings
@export var search_duration = 5.0
@export var search_radius = 3.0

# Waypoint settings
@export var waypoint_wait_time = 2.0

# State
var current_state = State.PATROL
var player: CharacterBody3D = null
var last_known_player_pos: Vector3
var search_timer = 0.0
var waypoint_timer = 0.0

# Patrol waypoints
var waypoints: Array[Node3D] = []
var current_waypoint_index = 0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	# Get waypoints from child node
	var waypoint_parent = get_node_or_null("Waypoints")
	if waypoint_parent:
		for child in waypoint_parent.get_children():
			if child is Node3D:
				waypoints.append(child)

	if waypoints.is_empty():
		push_warning("Enemy has no waypoints for patrol!")

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.PATROL:
			patrol_behavior(delta)
		State.CHASE:
			chase_behavior(delta)
		State.SEARCH:
			search_behavior(delta)

	# Check for player detection
	check_player_detection()

	move_and_slide()

func patrol_behavior(delta):
	if waypoints.is_empty():
		return

	var target_waypoint = waypoints[current_waypoint_index]
	var direction = (target_waypoint.global_position - global_position)
	direction.y = 0
	var distance = direction.length()

	if distance < 0.5:
		# Reached waypoint, wait before moving to next
		waypoint_timer += delta
		velocity.x = 0
		velocity.z = 0

		if waypoint_timer >= waypoint_wait_time:
			current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
			waypoint_timer = 0.0
	else:
		# Move toward waypoint
		direction = direction.normalized()
		velocity.x = direction.x * patrol_speed
		velocity.z = direction.z * patrol_speed

		# Rotate toward movement direction
		rotate_toward_direction(direction, delta)

func chase_behavior(delta):
	if not player or player.is_player_hiding():
		# Lost sight of player
		last_known_player_pos = global_position
		current_state = State.SEARCH
		search_timer = 0.0
		return

	# Move toward player
	var direction = (player.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed

	# Rotate toward player
	rotate_toward_direction(direction, delta)

	# Update last known position
	last_known_player_pos = player.global_position

func search_behavior(delta):
	search_timer += delta

	# Move toward last known position
	var direction = (last_known_player_pos - global_position)
	direction.y = 0
	var distance = direction.length()

	if distance > search_radius:
		direction = direction.normalized()
		velocity.x = direction.x * patrol_speed
		velocity.z = direction.z * patrol_speed
		rotate_toward_direction(direction, delta)
	else:
		# At search location, just look around
		velocity.x = 0
		velocity.z = 0

	# Return to patrol after search duration
	if search_timer >= search_duration:
		current_state = State.PATROL
		search_timer = 0.0

func check_player_detection():
	if not player or player.is_player_hiding():
		if current_state == State.CHASE:
			# Player started hiding, enter search mode
			last_known_player_pos = player.global_position
			current_state = State.SEARCH
			search_timer = 0.0
		return

	var direction_to_player = player.global_position - global_position
	var distance = direction_to_player.length()

	# Check range
	if distance > vision_range:
		return

	# Check angle
	direction_to_player = direction_to_player.normalized()
	var forward = -global_transform.basis.z.normalized()
	var angle = rad_to_deg(acos(forward.dot(direction_to_player)))

	if angle > vision_angle:
		return

	# Check line of sight
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1, 0),
		player.global_position + Vector3(0, 1, 0)
	)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result and result.collider == player:
		# Player detected!
		if current_state != State.CHASE:
			current_state = State.CHASE
			last_known_player_pos = player.global_position

func rotate_toward_direction(direction: Vector3, delta: float):
	var target_rotation = atan2(direction.x, direction.z)
	var current_rotation = rotation.y

	# Smooth rotation
	var rotation_diff = angle_difference(current_rotation, target_rotation)
	rotation.y += sign(rotation_diff) * min(abs(rotation_diff), rotation_speed * delta)

func angle_difference(from: float, to: float) -> float:
	var diff = fmod(to - from, TAU)
	return fmod(2.0 * diff, TAU) - diff
