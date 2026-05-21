extends Node

var accepted_events: Array[StringName] = []
var accepted_costs: Array[int] = []
var failed_events: Array[StringName] = []
var failed_reasons: Array[StringName] = []

const REASON_NOT_ENOUGH_ENERGY := &"not_enough_energy"
const REASON_UNKNOWN_ACTION := &"unknown_action"


func _ready() -> void:
	EventBus.overclock_action_accepted.connect(_on_overclock_action_accepted)
	EventBus.overclock_action_failed.connect(_on_overclock_action_failed)

	RunData.reset_run()
	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame
	var overclock_system: Node = player.get_node("OverclockSystem")

	await _test_attack_fails_without_energy(overclock_system)
	await _test_attack_accepts_with_energy(overclock_system)
	await _test_dodge_accepts_with_energy(overclock_system)
	await _test_parry_fails_with_low_energy(overclock_system)
	await _test_unknown_action_fails(overclock_system)
	get_tree().quit()


func _test_attack_fails_without_energy(overclock_system: Node) -> void:
	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame

	if overclock_system.is_action_accepted(&"attack"):
		_fail("Expected attack not accepted without energy.")
		return
	_expect_last_failure(&"attack", REASON_NOT_ENOUGH_ENERGY)
	print("TEST overclock attack failure ok")


func _test_attack_accepts_with_energy(overclock_system: Node) -> void:
	RunData.add_energy(3)
	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame

	if not overclock_system.is_action_accepted(&"attack"):
		_fail("Expected attack accepted with 3 energy.")
		return
	if overclock_system.get_action_cost(&"attack") != 3:
		_fail("Expected attack cost 3, got %d." % overclock_system.get_action_cost(&"attack"))
		return
	_expect_last_accepted(&"attack", 3)
	print("TEST overclock attack accepted ok")


func _test_dodge_accepts_with_energy(overclock_system: Node) -> void:
	RunData.add_energy(5)
	EventBus.emit_overclock_action_requested(&"dodge")
	await get_tree().process_frame

	if not overclock_system.is_action_accepted(&"dodge"):
		_fail("Expected dodge accepted with 8 energy.")
		return
	if overclock_system.get_action_cost(&"dodge") != 8:
		_fail("Expected dodge cost 8, got %d." % overclock_system.get_action_cost(&"dodge"))
		return
	_expect_last_accepted(&"dodge", 8)
	print("TEST overclock dodge accepted ok")


func _test_parry_fails_with_low_energy(overclock_system: Node) -> void:
	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame

	if overclock_system.is_action_accepted(&"parry"):
		_fail("Expected parry not accepted with 8 energy.")
		return
	_expect_last_failure(&"parry", REASON_NOT_ENOUGH_ENERGY)
	print("TEST overclock parry failure ok")


func _test_unknown_action_fails(overclock_system: Node) -> void:
	EventBus.emit_overclock_action_requested(&"interact")
	await get_tree().process_frame

	if overclock_system.is_action_accepted(&"interact"):
		_fail("Expected unknown action not accepted.")
		return
	_expect_last_failure(&"interact", REASON_UNKNOWN_ACTION)
	print("TEST overclock unknown action failure ok")


func _expect_last_accepted(expected_action: StringName, expected_cost: int) -> void:
	if accepted_events.is_empty():
		_fail("Expected accepted event %s, got none." % expected_action)
		return
	if accepted_events[-1] != expected_action or accepted_costs[-1] != expected_cost:
		_fail("Expected accepted %s/%d, got %s/%d." % [expected_action, expected_cost, accepted_events[-1], accepted_costs[-1]])


func _expect_last_failure(expected_action: StringName, expected_reason: StringName) -> void:
	if failed_events.is_empty():
		_fail("Expected failure event %s, got none." % expected_action)
		return
	if failed_events[-1] != expected_action or failed_reasons[-1] != expected_reason:
		_fail("Expected failure %s/%s, got %s/%s." % [expected_action, expected_reason, failed_events[-1], failed_reasons[-1]])


func _fail(message: String) -> void:
	push_error("TEST OverclockSystem failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_accepted(action_type: StringName, cost: int) -> void:
	accepted_events.append(action_type)
	accepted_costs.append(cost)


func _on_overclock_action_failed(action_type: StringName, reason: StringName) -> void:
	failed_events.append(action_type)
	failed_reasons.append(reason)
