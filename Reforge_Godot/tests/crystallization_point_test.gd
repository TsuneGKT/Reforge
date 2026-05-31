extends Node2D

const CRYSTALLIZATION_POINT_SCENE: PackedScene = preload("res://entities/interactables/crystallization_point/crystallization_point.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const STATE_DISABLED := &"disabled"
const STATE_AVAILABLE := &"available"
const STATE_USED := &"used"
const STATE_BLOCKED := &"blocked"

var failure_reasons: Array[StringName] = []


func _ready() -> void:
	EventBus.crystallization_failed.connect(_on_crystallization_failed)

	await _test_enable_and_success()
	await _test_not_enough_energy_failure()
	await _test_light_core_full_failure()

	print("TEST crystallization point ok")
	get_tree().quit()


func _test_enable_and_success() -> void:
	RunData.reset_run()
	failure_reasons.clear()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(point)
	await get_tree().process_frame

	if point.state != STATE_DISABLED or point.visible:
		_fail("Expected crystallization point to start disabled.")
		return

	EventBus.emit_all_enemies_cleared()
	if point.state != STATE_AVAILABLE or not point.visible:
		_fail("Expected all_enemies_cleared to enable crystallization point.")
		return

	point._on_body_entered(player)
	if not point.prompt_label.visible:
		_fail("Expected prompt to show when player enters range.")
		return

	RunData.add_energy(50)
	if not point.interact():
		_fail("Expected crystallization point interaction to succeed with 50 energy.")
		return
	if point.state != STATE_USED:
		_fail("Expected crystallization point to enter Used after success.")
		return
	if RunData.energy != 0 or not is_equal_approx(RunData.light_core_progress, 0.5):
		_fail("Expected 50 energy to become 0.5 light core progress.")
		return

	RunData.add_energy(50)
	if point.interact():
		_fail("Expected used crystallization point to reject repeated interaction.")
		return
	if RunData.energy != 50:
		_fail("Expected repeated interaction to keep energy unchanged.")
		return

	point.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_not_enough_energy_failure() -> void:
	RunData.reset_run()
	failure_reasons.clear()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(point)
	await get_tree().process_frame

	point.enable()
	point._on_body_entered(player)
	if point.interact():
		_fail("Expected crystallization to fail at 0 energy.")
		return
	if failure_reasons != [&"not_enough_energy"]:
		_fail("Expected not_enough_energy failure, got %s." % [failure_reasons])
		return
	if point.state != STATE_BLOCKED:
		_fail("Expected failed crystallization point to enter Blocked state.")
		return

	point.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_light_core_full_failure() -> void:
	RunData.reset_run()
	failure_reasons.clear()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(point)
	await get_tree().process_frame

	point.enable()
	point._on_body_entered(player)
	RunData.light_cores = RunData.max_light_cores
	RunData.add_energy(50)
	if point.interact():
		_fail("Expected crystallization to fail when light core storage is full.")
		return
	if RunData.energy != 50:
		_fail("Expected failed full-storage crystallization to keep energy.")
		return
	if failure_reasons != [&"light_core_full"]:
		_fail("Expected light_core_full failure, got %s." % [failure_reasons])
		return

	point.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _on_crystallization_failed(reason: StringName) -> void:
	failure_reasons.append(reason)


func _fail(message: String) -> void:
	push_error("TEST crystallization point failed. %s" % message)
	get_tree().quit(1)
