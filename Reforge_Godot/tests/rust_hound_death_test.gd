extends Node2D

const RUST_HOUND_SCENE: PackedScene = preload("res://entities/enemies/rust_hound/rust_hound.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

var died_enemies: Array[Node] = []


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

	var player: Player = PLAYER_SCENE.instantiate()
	var rust_hound: Node = RUST_HOUND_SCENE.instantiate()
	add_child(player)
	add_child(rust_hound)

	player.global_position = Vector2.ZERO
	rust_hound.global_position = Vector2(0.0, 28.0)
	player.set_facing_direction(Vector2.DOWN)

	await get_tree().physics_frame
	for i in range(4):
		await _player_attack_once(player)

	if rust_hound.health_component.current_health != 0:
		_fail("Expected rust hound health to reach 0, got %d." % rust_hound.health_component.current_health)
		return
	if not rust_hound.is_dead:
		_fail("Expected rust hound is_dead to be true.")
		return
	if rust_hound.state_machine.current_state.name != "DeadState":
		_fail("Expected rust hound to enter DeadState, got %s." % rust_hound.state_machine.current_state.name)
		return
	if died_enemies != [rust_hound]:
		_fail("Expected one enemy_died event for rust hound, got %s." % died_enemies)
		return
	if rust_hound.collision_layer != 0 or rust_hound.collision_mask != 0 or not rust_hound.collision_shape.disabled:
		_fail("Expected dead rust hound body collision to be disabled.")
		return
	if rust_hound.attack_hitbox.monitoring or not rust_hound.attack_collision_shape.disabled:
		_fail("Expected dead rust hound AttackHitbox to be disabled.")
		return

	await _player_attack_once(player)
	if died_enemies.size() != 1:
		_fail("Expected dead rust hound to emit enemy_died only once.")
		return

	print("TEST rust hound death ok")
	get_tree().quit()


func _player_attack_once(player: Player) -> void:
	player.set_attack_area_enabled(true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.resolve_attack_overlaps()
	player.set_attack_area_enabled(false)
	await get_tree().physics_frame


func _on_enemy_died(enemy: Node) -> void:
	died_enemies.append(enemy)


func _fail(message: String) -> void:
	push_error("TEST rust hound death failed. %s" % message)
	get_tree().quit(1)
