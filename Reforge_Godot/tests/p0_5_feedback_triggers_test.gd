extends Node2D

const ALTAR_SCENE: PackedScene = preload("res://entities/interactables/altar/altar.tscn")
const CRYSTALLIZATION_POINT_SCENE: PackedScene = preload("res://entities/interactables/crystallization_point/crystallization_point.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

var crystallization_successes: Array[float] = []
var crystallization_failures: Array[StringName] = []
var altar_activated_count := 0
var altar_failures: Array[StringName] = []
var talent_selection_requested_count := 0


func _ready() -> void:
	EventBus.crystallization_succeeded.connect(_on_crystallization_succeeded)
	EventBus.crystallization_failed.connect(_on_crystallization_failed)
	EventBus.altar_activated.connect(_on_altar_activated)
	EventBus.altar_failed.connect(_on_altar_failed)
	EventBus.talent_selection_requested.connect(_on_talent_selection_requested)

	await _test_crystallization_success_trigger()
	await _test_crystallization_failure_trigger()
	await _test_altar_success_trigger()
	await _test_altar_failure_trigger()

	print("TEST p0_5 feedback triggers ok")
	get_tree().quit()


func _test_crystallization_success_trigger() -> void:
	RunData.reset_run()
	_reset_counters()

	var player: Player = PLAYER_SCENE.instantiate()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	add_child(player)
	add_child(point)
	await get_tree().process_frame

	point.enable()
	point._on_body_entered(player)
	RunData.add_energy(50)
	if not point.interact():
		_fail("Expected crystallization interaction to succeed.")
		return
	if crystallization_successes.size() != 1 or not is_equal_approx(crystallization_successes[0], 0.5):
		_fail("Expected crystallization_succeeded progress 0.5, got %s." % [crystallization_successes])
		return
	if not crystallization_failures.is_empty():
		_fail("Expected no crystallization failure on success.")
		return

	point.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_crystallization_failure_trigger() -> void:
	RunData.reset_run()
	_reset_counters()

	var player: Player = PLAYER_SCENE.instantiate()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	add_child(player)
	add_child(point)
	await get_tree().process_frame

	point.enable()
	point._on_body_entered(player)
	if point.interact():
		_fail("Expected crystallization interaction to fail without energy.")
		return
	if not crystallization_successes.is_empty():
		_fail("Expected no crystallization success on failure.")
		return
	if crystallization_failures != [&"not_enough_energy"]:
		_fail("Expected not_enough_energy failure, got %s." % [crystallization_failures])
		return

	point.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_altar_success_trigger() -> void:
	RunData.reset_run()
	_reset_counters()

	var player: Player = PLAYER_SCENE.instantiate()
	var altar: Node = ALTAR_SCENE.instantiate()
	add_child(player)
	add_child(altar)
	await get_tree().process_frame

	RunData.light_cores = 1
	altar._on_body_entered(player)
	if not altar.interact():
		_fail("Expected altar interaction to succeed with 1 light core.")
		return
	if altar_activated_count != 1:
		_fail("Expected one altar_activated event.")
		return
	if talent_selection_requested_count != 1:
		_fail("Expected one talent_selection_requested event.")
		return
	if not altar_failures.is_empty():
		_fail("Expected no altar failure on success.")
		return

	altar.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_altar_failure_trigger() -> void:
	RunData.reset_run()
	_reset_counters()

	var player: Player = PLAYER_SCENE.instantiate()
	var altar: Node = ALTAR_SCENE.instantiate()
	add_child(player)
	add_child(altar)
	await get_tree().process_frame

	altar._on_body_entered(player)
	if altar.interact():
		_fail("Expected altar interaction to fail without light cores.")
		return
	if altar_activated_count != 0:
		_fail("Expected no altar_activated event on failure.")
		return
	if talent_selection_requested_count != 0:
		_fail("Expected no talent_selection_requested event on failure.")
		return
	if altar_failures != [&"not_enough_light_core"]:
		_fail("Expected not_enough_light_core failure, got %s." % [altar_failures])
		return

	altar.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _reset_counters() -> void:
	crystallization_successes.clear()
	crystallization_failures.clear()
	altar_activated_count = 0
	altar_failures.clear()
	talent_selection_requested_count = 0


func _on_crystallization_succeeded(converted_progress: float) -> void:
	crystallization_successes.append(converted_progress)


func _on_crystallization_failed(reason: StringName) -> void:
	crystallization_failures.append(reason)


func _on_altar_activated() -> void:
	altar_activated_count += 1


func _on_altar_failed(reason: StringName) -> void:
	altar_failures.append(reason)


func _on_talent_selection_requested() -> void:
	talent_selection_requested_count += 1


func _fail(message: String) -> void:
	push_error("TEST p0_5 feedback triggers failed. %s" % message)
	get_tree().quit(1)
