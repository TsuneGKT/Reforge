extends Node2D

const RUST_HOUND_SCENE: PackedScene = preload("res://entities/enemies/rust_hound/rust_hound.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")


func _ready() -> void:
	await _assert_lunge_locks_direction()
	await _assert_lunge_hits_player_once()
	print("TEST rust hound lunge ok")
	get_tree().quit()


func _assert_lunge_locks_direction() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var target := Node2D.new()
	add_child(rust_hound)
	add_child(target)

	rust_hound.global_position = Vector2.ZERO
	target.global_position = Vector2(rust_hound.data.attack_range - 8.0, 0.0)
	rust_hound.set_target(target)

	await _wait_for_state(rust_hound, "ChargeState", 0.2)
	if rust_hound.state_machine.current_state.name != "ChargeState":
		_fail("Expected ChargeState before lunge lock test.")
		return
	if rust_hound.locked_attack_direction.dot(Vector2.RIGHT) < 0.95:
		_fail("Expected rust hound to lock lunge direction to the right.")
		return

	target.global_position = Vector2(-160.0, 0.0)
	await _wait_for_state(rust_hound, "LungeState", rust_hound.data.charge_duration + 0.2)
	if rust_hound.state_machine.current_state.name != "LungeState":
		_fail("Expected LungeState after charge duration.")
		return
	if rust_hound.locked_attack_direction.dot(Vector2.RIGHT) < 0.95:
		_fail("Expected lunge direction to stay locked after target moved.")
		return
	if not rust_hound.attack_hitbox.monitoring or rust_hound.attack_collision_shape.disabled:
		_fail("Expected AttackHitbox enabled during LungeState.")
		return

	rust_hound.queue_free()
	target.queue_free()
	await get_tree().process_frame


func _assert_lunge_hits_player_once() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(rust_hound)
	add_child(player)

	rust_hound.global_position = Vector2.ZERO
	player.global_position = Vector2(rust_hound.data.attack_range - 8.0, 0.0)
	rust_hound.set_target(player)

	await _wait_for_player_damage(player, rust_hound.data.charge_duration + rust_hound.data.lunge_duration + 0.3)
	var expected_health: int = player.stats.max_health - rust_hound.data.attack_damage
	if player.health_component.current_health != expected_health:
		_fail("Expected player health %d after one lunge hit, got %d." % [expected_health, player.health_component.current_health])
		return

	rust_hound.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _wait_for_state(rust_hound: Node, state_name: String, timeout: float) -> void:
	var elapsed_time := 0.0
	while elapsed_time < timeout:
		await get_tree().physics_frame
		elapsed_time += 1.0 / float(Engine.physics_ticks_per_second)
		if rust_hound.state_machine.current_state != null and rust_hound.state_machine.current_state.name == state_name:
			return


func _wait_for_player_damage(player: Player, timeout: float) -> void:
	var elapsed_time := 0.0
	while elapsed_time < timeout:
		await get_tree().physics_frame
		elapsed_time += 1.0 / float(Engine.physics_ticks_per_second)
		if player.health_component.current_health < player.health_component.max_health:
			return


func _fail(message: String) -> void:
	push_error("TEST rust hound lunge failed. %s" % message)
	get_tree().quit(1)
