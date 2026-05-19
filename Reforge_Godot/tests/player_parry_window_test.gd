extends Node2D

const TEST_HITBOX_SCRIPT := preload("res://tests/test_parryable_hitbox.gd")

var player: Player
var parry_results: Array[bool] = []
var phase := "perfect"
var elapsed_time := 0.0
var spawned_normal_hitbox := false


func _ready() -> void:
	EventBus.parry_succeeded.connect(_on_parry_succeeded)
	_start_perfect_case()


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	if phase == "perfect" and elapsed_time > 0.1:
		_assert_case("perfect", [true])
		_start_normal_case()
		return

	if phase == "normal":
		if not spawned_normal_hitbox and elapsed_time > player.stats.perfect_parry_duration + 0.04:
			spawned_normal_hitbox = true
			_add_hitbox_in_front_of_player()

		if elapsed_time > player.stats.parry_window_duration + 0.1:
			_assert_case("normal", [true, false])
			get_tree().quit()


func _start_perfect_case() -> void:
	phase = "perfect"
	elapsed_time = 0.0
	player = _make_player()
	_add_hitbox_in_front_of_player()
	player.get_node("StateMachine").change_state(player.parry_state)


func _start_normal_case() -> void:
	phase = "normal"
	elapsed_time = 0.0
	spawned_normal_hitbox = false
	_clear_test_hitboxes()
	player.queue_free()
	player = _make_player()
	player.get_node("StateMachine").change_state(player.parry_state)


func _make_player() -> Player:
	var new_player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(new_player)
	new_player.global_position = Vector2.ZERO
	return new_player


func _add_hitbox_in_front_of_player() -> Area2D:
	var hitbox: Area2D = TEST_HITBOX_SCRIPT.new()
	hitbox.add_to_group("test_hitbox")
	add_child(hitbox)
	hitbox.global_position = player.parry_area.global_position
	return hitbox


func _clear_test_hitboxes() -> void:
	for hitbox in get_tree().get_nodes_in_group("test_hitbox"):
		hitbox.queue_free()


func _assert_case(label: String, expected_results: Array[bool]) -> void:
	if parry_results != expected_results:
		push_error("TEST %s failed. expected=%s actual=%s" % [label, expected_results, parry_results])
		get_tree().quit(1)
		return

	print("TEST %s parry ok results=%s" % [label, parry_results])


func _on_parry_succeeded(is_perfect: bool) -> void:
	parry_results.append(is_perfect)
