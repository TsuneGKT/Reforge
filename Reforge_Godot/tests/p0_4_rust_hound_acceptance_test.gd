extends Node2D

const RUST_HOUND_SCENE: PackedScene = preload("res://entities/enemies/rust_hound/rust_hound.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

var parry_results: Array[bool] = []
var died_enemies: Array[Node] = []


func _ready() -> void:
	EventBus.parry_succeeded.connect(_on_parry_succeeded)
	EventBus.enemy_died.connect(_on_enemy_died)

	await _assert_enemy_skeleton()
	await _assert_chase_flow()
	await _assert_lunge_damage()
	await _assert_parry_stun()
	await _assert_player_attack_kill()

	print("TEST P0-4 rust hound acceptance ok")
	get_tree().quit()


func _assert_enemy_skeleton() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	add_child(rust_hound)
	await get_tree().process_frame

	if rust_hound.data.max_health != 40:
		_fail("Expected rust hound max health 40.")
		return
	if rust_hound.data.attack_damage != 8:
		_fail("Expected rust hound attack damage 8.")
		return
	if rust_hound.attack_hitbox.collision_layer != 16 or rust_hound.attack_hitbox.collision_mask != 2:
		_fail("Expected AttackHitbox layer 16 and mask 2.")
		return
	if rust_hound.state_machine.current_state.name != "IdleState":
		_fail("Expected rust hound to start in IdleState.")
		return

	rust_hound.queue_free()
	await get_tree().process_frame


func _assert_chase_flow() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var target := Node2D.new()
	add_child(rust_hound)
	add_child(target)

	rust_hound.global_position = Vector2.ZERO
	target.global_position = Vector2(rust_hound.data.detection_range - 20.0, 0.0)
	rust_hound.set_target(target)

	await _wait_for_state(rust_hound, "ChaseState", 0.2)
	if rust_hound.state_machine.current_state.name != "ChaseState":
		_fail("Expected rust hound to chase target in detection range.")
		return

	var previous_distance: float = rust_hound.global_position.distance_to(target.global_position)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var current_distance: float = rust_hound.global_position.distance_to(target.global_position)
	if current_distance >= previous_distance:
		_fail("Expected rust hound to move closer while chasing.")
		return

	target.global_position = Vector2(rust_hound.data.disengage_range + 80.0, 0.0)
	await _wait_for_state(rust_hound, "IdleState", 0.2)
	if rust_hound.state_machine.current_state.name != "IdleState":
		_fail("Expected rust hound to return to IdleState after disengage.")
		return

	rust_hound.queue_free()
	target.queue_free()
	await get_tree().process_frame


func _assert_lunge_damage() -> void:
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(rust_hound)

	rust_hound.global_position = Vector2.ZERO
	player.global_position = Vector2(rust_hound.data.attack_range - 8.0, 0.0)
	rust_hound.set_target(player)

	await _wait_for_player_damage(player, rust_hound.data.charge_duration + rust_hound.data.lunge_duration + 0.3)
	if player.health_component.current_health != player.stats.max_health - rust_hound.data.attack_damage:
		_fail("Expected lunge to deal 8 damage to player.")
		return

	rust_hound.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _assert_parry_stun() -> void:
	parry_results.clear()

	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(rust_hound)

	rust_hound.global_position = Vector2.ZERO
	player.global_position = Vector2(rust_hound.data.attack_range - 8.0, 0.0)
	player.set_facing_direction(Vector2.LEFT)
	rust_hound.set_target(player)

	await _wait_for_state(rust_hound, "ChargeState", 0.2)
	await get_tree().create_timer(maxf(rust_hound.data.charge_duration - 0.1, 0.0)).timeout
	player.state_machine.change_state(player.parry_state)
	await get_tree().physics_frame
	await _wait_for_state(rust_hound, "ParriedStunState", rust_hound.data.charge_duration + 0.2)

	if parry_results.size() != 1:
		_fail("Expected one parry result, got %s." % [parry_results])
		return
	if rust_hound.state_machine.current_state.name != "ParriedStunState":
		_fail("Expected rust hound to enter ParriedStunState after parry.")
		return
	if player.health_component.current_health != player.stats.max_health:
		_fail("Expected player to avoid damage after parry.")
		return

	rust_hound.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _assert_player_attack_kill() -> void:
	died_enemies.clear()

	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(rust_hound)

	player.global_position = Vector2.ZERO
	rust_hound.global_position = Vector2(0.0, 28.0)
	player.set_facing_direction(Vector2.DOWN)

	await get_tree().physics_frame
	for i in range(4):
		await _player_attack_once(player)

	if not rust_hound.is_dead:
		_fail("Expected rust hound to be dead after four player attacks.")
		return
	if rust_hound.state_machine.current_state.name != "DeadState":
		_fail("Expected rust hound to enter DeadState after lethal damage.")
		return
	if died_enemies != [rust_hound]:
		_fail("Expected one enemy_died event for rust hound, got %s." % died_enemies)
		return
	if rust_hound.collision_layer != 0 or rust_hound.attack_hitbox.monitoring:
		_fail("Expected dead rust hound combat collisions to be disabled.")
		return

	await _player_attack_once(player)
	if died_enemies.size() != 1:
		_fail("Expected dead rust hound to emit enemy_died only once.")
		return

	rust_hound.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _player_attack_once(player: Player) -> void:
	player.set_attack_area_enabled(true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.resolve_attack_overlaps()
	player.set_attack_area_enabled(false)
	await get_tree().physics_frame


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


func _on_parry_succeeded(is_perfect: bool) -> void:
	parry_results.append(is_perfect)


func _on_enemy_died(enemy: Node) -> void:
	died_enemies.append(enemy)


func _fail(message: String) -> void:
	push_error("TEST P0-4 rust hound acceptance failed. %s" % message)
	get_tree().quit(1)
