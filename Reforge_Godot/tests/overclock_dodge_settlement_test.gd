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

	await _test_dodge_started_consumes_energy(overclock_system)
	await _test_low_energy_dodge_does_not_consume(overclock_system)
	await get_tree().create_timer(0.14).timeout
	get_tree().quit()


func _test_dodge_started_consumes_energy(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(10)

	EventBus.emit_overclock_action_requested(&"dodge")
	await get_tree().process_frame
	EventBus.emit_dodge_started()
	await get_tree().process_frame

	if RunData.energy != 2:
		_fail("Expected overclock dodge to consume 8 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"dodge"):
		_fail("Expected dodge candidate cleared after trigger.")
		return
	_expect_last_triggered(&"dodge", 8)
	print("TEST overclock dodge consumes energy ok")


func _test_low_energy_dodge_does_not_consume(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(7)

	var trigger_count := triggered_events.size()
	EventBus.emit_overclock_action_requested(&"dodge")
	await get_tree().process_frame
	EventBus.emit_dodge_started()
	await get_tree().process_frame

	if RunData.energy != 7:
		_fail("Expected low energy dodge to keep 7 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"dodge"):
		_fail("Expected low energy dodge not accepted.")
		return
	if triggered_events.size() != trigger_count:
		_fail("Expected low energy dodge not to trigger overclock.")
		return
	_expect_last_failure(&"dodge", &"not_enough_energy")
	print("TEST overclock low energy dodge no consume ok")


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
	push_error("TEST overclock dodge settlement failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_triggered(action_type: StringName, cost: int) -> void:
	triggered_events.append(action_type)
	triggered_costs.append(cost)


func _on_overclock_action_failed(action_type: StringName, reason: StringName) -> void:
	failed_events.append(action_type)
	failed_reasons.append(reason)
