extends Node

var player: Node
var hud: CanvasLayer
var triggered_events: Array[StringName] = []
var failed_events: Array[StringName] = []
var failed_reasons: Array[StringName] = []


func _ready() -> void:
	EventBus.overclock_action_triggered.connect(_on_overclock_action_triggered)
	EventBus.overclock_action_failed.connect(_on_overclock_action_failed)

	player = preload("res://entities/player/player.tscn").instantiate()
	player.name = "Player"
	add_child(player)

	hud = preload("res://ui/hud/energy_hud.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame

	await _test_run_data_and_hud()
	await _test_parry_energy_gain()
	await _test_overclock_attack()
	await _test_overclock_dodge()
	await _test_overclock_parry()
	await _test_not_enough_energy_downgrade()
	await get_tree().create_timer(0.14).timeout

	print("TEST P0-3 energy acceptance ok")
	get_tree().quit()


func _test_run_data_and_hud() -> void:
	RunData.reset_run()
	await get_tree().process_frame

	if RunData.energy != 0 or RunData.max_energy != 100:
		_fail("Expected RunData energy 0/100.")
		return
	if RunData.light_core_progress != 0.0 or RunData.light_cores != 0 or RunData.max_light_cores != 1:
		_fail("Expected RunData light core fields to reset.")
		return

	var energy_label: Label = hud.get_node("Panel/EnergyLabel")
	if energy_label.text != "Energy 0/100":
		_fail("Expected HUD energy 0/100, got %s." % energy_label.text)
		return

	RunData.add_energy(999)
	await get_tree().process_frame
	if RunData.energy != 100 or energy_label.text != "Energy 100/100":
		_fail("Expected energy clamp and HUD 100/100, got %d and %s." % [RunData.energy, energy_label.text])
		return

	RunData.consume_energy(999)
	if RunData.energy != 100:
		_fail("Expected failed consume to keep energy at 100.")
		return
	print("TEST P0-3 RunData and HUD ok")


func _test_parry_energy_gain() -> void:
	RunData.reset_run()
	await get_tree().process_frame

	EventBus.emit_parry_succeeded(true)
	await get_tree().process_frame
	if RunData.energy != 12:
		_fail("Expected perfect parry to add 12 energy, got %d." % RunData.energy)
		return

	EventBus.emit_parry_succeeded(false)
	await get_tree().process_frame
	if RunData.energy != 18:
		_fail("Expected normal parry to add 6 energy after perfect, got %d." % RunData.energy)
		return

	var energy_label: Label = hud.get_node("Panel/EnergyLabel")
	if energy_label.text != "Energy 18/100":
		_fail("Expected HUD energy 18/100, got %s." % energy_label.text)
		return
	print("TEST P0-3 parry energy ok")


func _test_overclock_attack() -> void:
	RunData.reset_run()
	RunData.add_energy(10)

	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame
	EventBus.emit_attack_finished()
	await get_tree().process_frame
	if RunData.energy != 10:
		_fail("Expected empty overclock attack to keep 10 energy, got %d." % RunData.energy)
		return

	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame
	EventBus.emit_attack_landed(10)
	await get_tree().process_frame
	if RunData.energy != 7:
		_fail("Expected overclock attack hit to consume 3 energy, got %d." % RunData.energy)
		return
	_expect_last_triggered(&"attack")
	print("TEST P0-3 overclock attack ok")


func _test_overclock_dodge() -> void:
	RunData.reset_run()
	RunData.add_energy(10)

	EventBus.emit_overclock_action_requested(&"dodge")
	await get_tree().process_frame
	EventBus.emit_dodge_started()
	await get_tree().process_frame
	if RunData.energy != 2:
		_fail("Expected overclock dodge to consume 8 energy, got %d." % RunData.energy)
		return
	_expect_last_triggered(&"dodge")
	print("TEST P0-3 overclock dodge ok")


func _test_overclock_parry() -> void:
	RunData.reset_run()
	RunData.add_energy(15)

	var trigger_count := triggered_events.size()
	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_failed()
	await get_tree().process_frame
	if RunData.energy != 15 or triggered_events.size() != trigger_count:
		_fail("Expected failed overclock parry not to consume or trigger.")
		return

	EventBus.emit_overclock_action_requested(&"parry")
	await get_tree().process_frame
	EventBus.emit_parry_succeeded(true)
	await get_tree().process_frame
	if RunData.energy != 12:
		_fail("Expected perfect overclock parry net 12 energy, got %d." % RunData.energy)
		return
	_expect_last_triggered(&"parry")
	print("TEST P0-3 overclock parry ok")


func _test_not_enough_energy_downgrade() -> void:
	RunData.reset_run()
	RunData.add_energy(2)

	var trigger_count := triggered_events.size()
	EventBus.emit_overclock_action_requested(&"attack")
	await get_tree().process_frame
	EventBus.emit_attack_landed(10)
	await get_tree().process_frame

	if RunData.energy != 2:
		_fail("Expected not enough energy attack to keep 2 energy, got %d." % RunData.energy)
		return
	if triggered_events.size() != trigger_count:
		_fail("Expected not enough energy action not to trigger overclock.")
		return
	_expect_last_failure(&"attack", &"not_enough_energy")
	print("TEST P0-3 not enough energy downgrade ok")


func _expect_last_triggered(expected_action: StringName) -> void:
	if triggered_events.is_empty():
		_fail("Expected triggered event %s, got none." % expected_action)
		return
	if triggered_events[-1] != expected_action:
		_fail("Expected triggered %s, got %s." % [expected_action, triggered_events[-1]])


func _expect_last_failure(expected_action: StringName, expected_reason: StringName) -> void:
	if failed_events.is_empty():
		_fail("Expected failure event %s, got none." % expected_action)
		return
	if failed_events[-1] != expected_action or failed_reasons[-1] != expected_reason:
		_fail("Expected failure %s/%s, got %s/%s." % [expected_action, expected_reason, failed_events[-1], failed_reasons[-1]])


func _fail(message: String) -> void:
	push_error("TEST P0-3 energy acceptance failed. %s" % message)
	get_tree().quit(1)


func _on_overclock_action_triggered(action_type: StringName, _cost: int) -> void:
	triggered_events.append(action_type)


func _on_overclock_action_failed(action_type: StringName, reason: StringName) -> void:
	failed_events.append(action_type)
	failed_reasons.append(reason)
