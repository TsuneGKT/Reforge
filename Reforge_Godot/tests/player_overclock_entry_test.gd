extends Node2D

var player: Player
var overclock_events: Array[bool] = []


func _ready() -> void:
	EventBus.overclock_toggled.connect(_on_overclock_toggled)

	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame

	await _test_idle_toggle()
	await _test_attack_toggle_does_not_interrupt()
	await _test_stun_blocks_toggle()
	await _test_death_forces_overclock_off()
	get_tree().quit()


func _test_idle_toggle() -> void:
	if not player.toggle_overclock():
		_fail("Expected overclock toggle from Idle.")
		return
	if not player.is_overclock_active:
		_fail("Expected overclock active after first toggle.")
		return
	if not player.toggle_overclock():
		_fail("Expected overclock toggle off from Idle.")
		return
	if player.is_overclock_active:
		_fail("Expected overclock inactive after second toggle.")
		return
	if overclock_events != [true, false]:
		_fail("Expected idle toggle events [true, false], got %s." % overclock_events)
		return
	print("TEST overclock idle toggle ok")


func _test_attack_toggle_does_not_interrupt() -> void:
	player.state_machine.change_state(player.attack_state)
	await get_tree().physics_frame
	if not player.toggle_overclock():
		_fail("Expected overclock toggle during Attack.")
		return
	if player.state_machine.current_state != player.attack_state:
		_fail("Expected AttackState to continue after overclock toggle.")
		return
	print("TEST overclock attack overlay ok")


func _test_stun_blocks_toggle() -> void:
	player.receive_damage(1)
	await get_tree().physics_frame
	var event_count := overclock_events.size()
	if player.toggle_overclock():
		_fail("Expected overclock toggle to be blocked during Stun.")
		return
	if overclock_events.size() != event_count:
		_fail("Expected no overclock event during Stun.")
		return
	print("TEST overclock stun block ok")


func _test_death_forces_overclock_off() -> void:
	for i in range(30):
		await get_tree().physics_frame

	if not player.is_overclock_active:
		player.toggle_overclock()

	player.receive_damage(999)
	await get_tree().physics_frame

	if player.is_overclock_active:
		_fail("Expected overclock inactive after death.")
		return
	if player.state_machine.current_state != player.dead_state:
		_fail("Expected DeadState after lethal damage.")
		return
	if overclock_events[-1] != false:
		_fail("Expected death to emit overclock false, got events %s." % overclock_events)
		return
	print("TEST overclock death forced off ok")


func _fail(message: String) -> void:
	push_error("TEST overclock entry failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_toggled(is_active: bool) -> void:
	overclock_events.append(is_active)
