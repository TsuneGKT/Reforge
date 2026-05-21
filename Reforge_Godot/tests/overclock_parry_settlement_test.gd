extends Node

var triggered_events: Array[StringName] = []
var triggered_costs: Array[int] = []
var failed_events: Array[StringName] = []
var failed_reasons: Array[StringName] = []


func _ready() -> void:
	EventBus.overclock_action_triggered.connect(_on_overclock_action_triggered)
	EventBus.overclock_action_failed.connect(_on_overclock_action_failed)

	RunData.reset_run()
	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame
	var overclock_system: Node = player.get_node("OverclockSystem")

	await _test_perfect_parry_adds_then_consumes(overclock_system)
	await _test_normal_parry_adds_then_consumes(overclock_system)
	await _test_failed_parry_does_not_consume(overclock_system)
	await _test_low_energy_request_does_not_consume_after_success(overclock_system)
	await get_tree().create_timer(0.14).timeout
	get_tree().quit()


func _test_perfect_parry_adds_then_consumes(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(15)

	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_succeeded(true)
	await get_tree().process_frame

	if RunData.energy != 12:
		_fail("Expected perfect overclock parry net energy 12, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"parry"):
		_fail("Expected parry candidate cleared after success.")
		return
	_expect_last_triggered(&"parry", 15)
	print("TEST overclock perfect parry settlement ok")


func _test_normal_parry_adds_then_consumes(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(15)

	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_succeeded(false)
	await get_tree().process_frame

	if RunData.energy != 6:
		_fail("Expected normal overclock parry net energy 6, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"parry"):
		_fail("Expected parry candidate cleared after normal success.")
		return
	_expect_last_triggered(&"parry", 15)
	print("TEST overclock normal parry settlement ok")


func _test_failed_parry_does_not_consume(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(15)

	var trigger_count := triggered_events.size()
	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_failed()
	await get_tree().process_frame

	if RunData.energy != 15:
		_fail("Expected failed overclock parry to keep 15 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"parry"):
		_fail("Expected failed parry to clear parry candidate.")
		return
	if triggered_events.size() != trigger_count:
		_fail("Expected failed parry not to trigger overclock.")
		return
	print("TEST overclock failed parry no consume ok")


func _test_low_energy_request_does_not_consume_after_success(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(14)

	var trigger_count := triggered_events.size()
	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_succeeded(true)
	await get_tree().process_frame

	if RunData.energy != 26:
		_fail("Expected low energy parry request to only gain 12 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"parry"):
		_fail("Expected low energy request not accepted.")
		return
	if triggered_events.size() != trigger_count:
		_fail("Expected low energy request not to trigger overclock after success.")
		return
	_expect_last_failure(&"parry", &"not_enough_energy")
	print("TEST overclock low energy parry no consume ok")


func _expect_last_triggered(expected_action: StringName, expected_cost: int) -> void:
	if triggered_events.is_empty():
		_fail("Expected triggered event %s, got none." % expected_action)
		return
	if triggered_events[-1] != expected_action or triggered_costs[-1] != expected_cost:
		_fail("Expected triggered %s/%d, got %s/%d." % [expected_action, expected_cost, triggered_events[-1], triggered_costs[-1]])


func _expect_last_failure(expected_action: StringName, expected_reason: StringName) -> void:
	if failed_events.is_empty():
		_fail("Expected failure event %s, got none." % expected_action)
		return
	if failed_events[-1] != expected_action or failed_reasons[-1] != expected_reason:
		_fail("Expected failure %s/%s, got %s/%s." % [expected_action, expected_reason, failed_events[-1], failed_reasons[-1]])


func _fail(message: String) -> void:
	push_error("TEST overclock parry settlement failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_triggered(action_type: StringName, cost: int) -> void:
	triggered_events.append(action_type)
	triggered_costs.append(cost)


func _on_overclock_action_failed(action_type: StringName, reason: StringName) -> void:
	failed_events.append(action_type)
	failed_reasons.append(reason)
