extends Node2D

var player: Player


func _ready() -> void:
	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame

	await _test_stun_state()
	await _test_dead_state()
	get_tree().quit()


func _test_stun_state() -> void:
	player.receive_damage(10)
	await get_tree().physics_frame

	var current_state_name: String = player.get_node("StateMachine").current_state.name
	if current_state_name != "StunState":
		_fail("Expected StunState after damage, got %s." % current_state_name)
		return
	if player.can_receive_damage():
		_fail("Expected player to be invincible during stun.")
		return

	for i in range(30):
		await get_tree().physics_frame

	current_state_name = player.get_node("StateMachine").current_state.name
	if current_state_name != "IdleState":
		_fail("Expected IdleState after stun, got %s." % current_state_name)
		return

	print("TEST player stun state ok")


func _test_dead_state() -> void:
	player.receive_damage(999)
	await get_tree().physics_frame

	var current_state_name: String = player.get_node("StateMachine").current_state.name
	if current_state_name != "DeadState":
		_fail("Expected DeadState after lethal damage, got %s." % current_state_name)
		return
	if player.is_attack_area_active or player.is_parry_area_active:
		_fail("Expected attack and parry areas to be inactive after death.")
		return

	Input.action_press("attack")
	await get_tree().physics_frame
	Input.action_release("attack")

	current_state_name = player.get_node("StateMachine").current_state.name
	if current_state_name != "DeadState":
		_fail("Expected DeadState to ignore input, got %s." % current_state_name)
		return

	print("TEST player dead state ok")


func _fail(message: String) -> void:
	push_error("TEST player stun/dead failed. %s" % message)
	get_tree().quit(1)
