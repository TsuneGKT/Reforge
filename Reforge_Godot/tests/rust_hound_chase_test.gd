extends Node2D


func _ready() -> void:
	var rust_hound: Node = preload("res://entities/enemies/rust_hound/rust_hound.tscn").instantiate()
	var player := Node2D.new()
	player.name = "Player"
	add_child(rust_hound)
	add_child(player)

	rust_hound.global_position = Vector2.ZERO
	player.global_position = Vector2(rust_hound.data.detection_range + 10.0, 0.0)
	rust_hound.set_target(player)
	await get_tree().physics_frame

	if rust_hound.state_machine.current_state.name != "IdleState":
		_fail("Expected rust hound to stay Idle when player is outside detection range.")
		return

	player.global_position = Vector2(rust_hound.data.detection_range - 20.0, 0.0)
	await get_tree().physics_frame
	if rust_hound.state_machine.current_state.name != "ChaseState":
		_fail("Expected rust hound to enter ChaseState when player enters detection range.")
		return

	var previous_distance: float = rust_hound.global_position.distance_to(player.global_position)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var current_distance: float = rust_hound.global_position.distance_to(player.global_position)
	if current_distance >= previous_distance:
		_fail("Expected rust hound to move closer during chase. before=%s after=%s" % [previous_distance, current_distance])
		return

	if rust_hound.last_facing_direction.dot(Vector2.RIGHT) < 0.9:
		_fail("Expected rust hound to face toward player while chasing.")
		return

	player.global_position = Vector2(rust_hound.data.disengage_range + 80.0, 0.0)
	await get_tree().physics_frame
	if rust_hound.state_machine.current_state.name != "IdleState":
		_fail("Expected rust hound to return Idle when player leaves disengage range.")
		return

	print("TEST rust hound chase ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST rust hound chase failed. %s" % message)
	get_tree().quit(1)
