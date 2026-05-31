extends Node

var crystallization_failures: Array[StringName] = []
var crystallization_successes: Array[float] = []
var altar_activated_count := 0
var altar_failures: Array[StringName] = []
var talent_selection_requested_count := 0


func _ready() -> void:
	EventBus.crystallization_succeeded.connect(_on_crystallization_succeeded)
	EventBus.crystallization_failed.connect(_on_crystallization_failed)
	EventBus.altar_activated.connect(_on_altar_activated)
	EventBus.altar_failed.connect(_on_altar_failed)
	EventBus.talent_selection_requested.connect(_on_talent_selection_requested)

	EventBus.emit_crystallization_succeeded(0.5)
	EventBus.emit_crystallization_failed(&"light_core_full")
	EventBus.emit_altar_activated()
	EventBus.emit_altar_failed(&"not_enough_light_core")
	EventBus.emit_talent_selection_requested()

	if crystallization_successes.size() != 1 or not is_equal_approx(crystallization_successes[0], 0.5):
		_fail("Expected crystallization_succeeded progress 0.5.")
		return
	if crystallization_failures != [&"light_core_full"]:
		_fail("Expected crystallization_failed reason light_core_full.")
		return
	if altar_activated_count != 1:
		_fail("Expected one altar_activated event.")
		return
	if altar_failures != [&"not_enough_light_core"]:
		_fail("Expected altar_failed reason not_enough_light_core.")
		return
	if talent_selection_requested_count != 1:
		_fail("Expected one talent_selection_requested event.")
		return

	print("TEST P0-5 EventBus signals ok")
	get_tree().quit()


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
	push_error("TEST P0-5 EventBus signals failed. %s" % message)
	get_tree().quit(1)
