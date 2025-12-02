extends Area3D

@export var hide_position_offset = Vector3(0, 0, 0)

var player_in_range = false
var player: CharacterBody3D = null
var is_occupied = false

@onready var label = $Label3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if label:
		label.visible = false

func _process(_delta):
	if player_in_range and not is_occupied:
		if label:
			label.visible = true

		if Input.is_action_just_pressed("interact"):
			enter_hiding()
	elif is_occupied:
		if label:
			label.text = "Press E to Exit"
			label.visible = true

		if Input.is_action_just_pressed("interact"):
			exit_hiding()
	else:
		if label:
			label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		if not is_occupied:
			player = null

func enter_hiding():
	if player and not is_occupied:
		is_occupied = true
		player.set_hiding(true)

		# Move player to hiding position
		var hide_pos = global_position + hide_position_offset
		player.global_position = hide_pos

		# Disable player collision while hiding
		if player.has_node("CollisionShape3D"):
			player.get_node("CollisionShape3D").disabled = true

func exit_hiding():
	if player and is_occupied:
		is_occupied = false
		player.set_hiding(false)

		# Re-enable player collision
		if player.has_node("CollisionShape3D"):
			player.get_node("CollisionShape3D").disabled = false

		# Move player slightly forward to exit
		player.global_position += -player.global_transform.basis.z * 2.0

		player_in_range = false
		player = null
