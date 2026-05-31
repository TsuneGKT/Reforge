extends Node2D

const RUST_HOUND_SCENE: PackedScene = preload("res://entities/enemies/rust_hound/rust_hound.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

var parry_results: Array[bool] = []


func _ready() -> void:
	EventBus.parry_succeeded.connect(_on_parry_succeeded)

	var player: Player = PLAYER_SCENE.instantiate()
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	add_child(player)
	add_child(rust_hound)

	rust_hound.global_position = Vector2.ZERO
	player.global_position = Vector2(rust_hound.data.attack_range - 8.0, 0.0)
	player.set_facing_direction(Vector2.LEFT)
	rust_hound.set_target(player)

	await _wait_for_state(rust_hound, "LungeState", rust_hound.data.charge_duration + 0.2)
	if rust_hound.state_machine.current_state.name != "LungeState":
		_fail("Expected rust hound to enter LungeState before parry.")
		return

	player.state_machine.change_state(player.parry_state)
	await get_tree().physics_frame
	await get_tree().physics_frame

	if parry_results != [true]:
		_fail("Expected player to emit one perfect parry result, got %s." % parry_results)
		return
	if rust_hound.state_machine.current_state.name != "ParriedStunState":
		_fail("Expected rust hound to enter ParriedStunState after parry, got %s." % rust_hound.state_machine.current_state.name)
		return
	if rust_hound.attack_hitbox.monitoring or not rust_hound.attack_collision_shape.disabled:
		_fail("Expected rust hound AttackHitbox to close after parry.")
		return
	if player.health_component.current_health != player.stats.max_health:
		_fail("Expected player to avoid damage after parry.")
		return

	await _wait_for_state(rust_hound, "ChaseState", rust_hound.data.stun_duration + 0.3)
	if rust_hound.state_machine.current_state.name != "ChaseState":
		_fail("Expected rust hound to return to ChaseState after stun.")
		return

	print("TEST rust hound parry ok")
	get_tree().quit()


func _wait_for_state(rust_hound: Node, state_name: String, timeout: float) -> void:
	var elapsed_time := 0.0
	while elapsed_time < timeout:
		await get_tree().physics_frame
		elapsed_time += 1.0 / float(Engine.physics_ticks_per_second)
		if rust_hound.state_machine.current_state != null and rust_hound.state_machine.current_state.name == state_name:
			return


func _on_parry_succeeded(is_perfect: bool) -> void:
	parry_results.append(is_perfect)


func _fail(message: String) -> void:
	push_error("TEST rust hound parry failed. %s" % message)
	get_tree().quit(1)
