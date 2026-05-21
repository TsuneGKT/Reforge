extends Node2D

var player: Player
var requested_actions: Array[StringName] = []


func _ready() -> void:
	EventBus.overclock_action_requested.connect(_on_overclock_action_requested)

	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame

	await _test_pressing_overclock_alone_does_not_request()
	await _test_attack_request()
	await _test_dodge_request()
	await _test_parry_request()
	await _test_stun_blocks_request()
	get_tree().quit()


func _test_pressing_overclock_alone_does_not_request() -> void:
	Input.action_press("overclock")
	await get_tree().process_frame
	Input.action_release("overclock")

	if not requested_actions.is_empty():
		_fail("Expected no request from pressing overclock alone, got %s." % requested_actions)
		return
	print("TEST overclock alone no request ok")


func _test_attack_request() -> void:
	Input.action_press("overclock")
	player.state_machine.change_state(player.attack_state)
	await get_tree().physics_frame
	Input.action_release("overclock")

	_expect_last_request(&"attack")
	print("TEST overclock attack request ok")


func _test_dodge_request() -> void:
	_return_to_idle()
	Input.action_press("overclock")
	player.state_machine.change_state(player.dodge_state)
	await get_tree().physics_frame
	Input.action_release("overclock")

	_expect_last_request(&"dodge")
	print("TEST overclock dodge request ok")


func _test_parry_request() -> void:
	_return_to_idle()
	Input.action_press("overclock")
	player.state_machine.change_state(player.parry_state)
	await get_tree().physics_frame
	Input.action_release("overclock")

	_expect_last_request(&"parry")
	print("TEST overclock parry request ok")


func _test_stun_blocks_request() -> void:
	_return_to_idle()
	player.receive_damage(1)
	await get_tree().physics_frame

	var request_count := requested_actions.size()
	Input.action_press("overclock")
	if player.request_overclock_action(&"attack"):
		_fail("Expected overclock request to be blocked during Stun.")
		return
	Input.action_release("overclock")

	if requested_actions.size() != request_count:
		_fail("Expected no request event during Stun, got %s." % requested_actions)
		return
	print("TEST overclock stun block ok")


func _return_to_idle() -> void:
	player.set_attack_area_enabled(false)
	player.set_parry_area_enabled(false)
	player.set_dodge_visual_enabled(false)
	player.set_invincible(false)
	player.state_machine.change_state(player.idle_state)


func _expect_last_request(expected_action: StringName) -> void:
	if requested_actions.is_empty():
		_fail("Expected %s request, got none." % expected_action)
		return
	if requested_actions[-1] != expected_action:
		_fail("Expected %s request, got %s." % [expected_action, requested_actions[-1]])


func _fail(message: String) -> void:
	push_error("TEST overclock entry failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_requested(action_type: StringName) -> void:
	requested_actions.append(action_type)
