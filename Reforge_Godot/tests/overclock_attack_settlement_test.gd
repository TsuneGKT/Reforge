extends Node

var triggered_events: Array[StringName] = []
var triggered_costs: Array[int] = []


func _ready() -> void:
	EventBus.overclock_action_triggered.connect(_on_overclock_action_triggered)

	RunData.reset_run()
	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame
	var overclock_system: Node = player.get_node("OverclockSystem")

	await _test_attack_hit_consumes_energy(overclock_system)
	await _test_empty_attack_does_not_consume(overclock_system)
	await get_tree().create_timer(0.14).timeout
	get_tree().quit()


func _test_attack_hit_consumes_energy(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(10)

	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame
	EventBus.emit_attack_landed(10)
	await get_tree().process_frame

	if RunData.energy != 7:
		_fail("Expected overclock attack hit to consume 3 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"attack"):
		_fail("Expected attack candidate cleared after hit.")
		return
	_expect_last_triggered(&"attack", 3)
	print("TEST overclock attack hit consumes energy ok")


func _test_empty_attack_does_not_consume(overclock_system: Node) -> void:
	RunData.reset_run()
	RunData.add_energy(10)

	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame
	EventBus.emit_attack_finished()
	await get_tree().process_frame

	if RunData.energy != 10:
		_fail("Expected empty overclock attack to keep 10 energy, got %d." % RunData.energy)
		return
	if overclock_system.is_action_accepted(&"attack"):
		_fail("Expected empty attack to clear attack candidate.")
		return

	var trigger_count := triggered_events.size()
	EventBus.emit_attack_landed(10)
	await get_tree().process_frame
	if RunData.energy != 10:
		_fail("Expected later normal hit not to consume energy, got %d." % RunData.energy)
		return
	if triggered_events.size() != trigger_count:
		_fail("Expected no trigger after empty attack cleared candidate.")
		return
	print("TEST overclock empty attack no consume ok")


func _expect_last_triggered(expected_action: StringName, expected_cost: int) -> void:
	if triggered_events.is_empty():
		_fail("Expected triggered event %s, got none." % expected_action)
		return
	if triggered_events[-1] != expected_action or triggered_costs[-1] != expected_cost:
		_fail("Expected triggered %s/%d, got %s/%d." % [expected_action, expected_cost, triggered_events[-1], triggered_costs[-1]])


func _fail(message: String) -> void:
	push_error("TEST overclock attack settlement failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_triggered(action_type: StringName, cost: int) -> void:
	triggered_events.append(action_type)
	triggered_costs.append(cost)
