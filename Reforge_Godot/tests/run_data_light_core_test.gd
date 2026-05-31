extends Node

var light_core_events: Array[float] = []
var crystallization_successes: Array[float] = []
var crystallization_completed_count := 0


func _ready() -> void:
	EventBus.light_core_changed.connect(_on_light_core_changed)
	EventBus.crystallization_succeeded.connect(_on_crystallization_succeeded)
	EventBus.crystallization_completed.connect(_on_crystallization_completed)

	_test_half_energy_crystallize()
	_test_full_energy_crystallize()
	_test_crystallize_full_storage_keeps_energy()
	_test_spend_light_core()

	print("TEST RunData light core interface ok")
	get_tree().quit()


func _test_half_energy_crystallize() -> void:
	RunData.reset_run()
	crystallization_successes.clear()
	RunData.add_energy(50)

	if not RunData.crystallize():
		_fail("Expected crystallize at 50 energy to succeed.")
		return
	if RunData.energy != 0:
		_fail("Expected successful crystallize to clear energy.")
		return
	if not is_equal_approx(RunData.light_core_progress, 0.5):
		_fail("Expected light core progress 0.5, got %s." % RunData.light_core_progress)
		return
	if RunData.light_cores != 0:
		_fail("Expected no full light core after 50 energy.")
		return
	if crystallization_successes.size() != 1 or not is_equal_approx(crystallization_successes[0], 0.5):
		_fail("Expected crystallization_succeeded progress 0.5.")
		return


func _test_full_energy_crystallize() -> void:
	RunData.reset_run()
	crystallization_successes.clear()
	crystallization_completed_count = 0
	RunData.add_energy(100)

	if not RunData.crystallize():
		_fail("Expected crystallize at 100 energy to succeed.")
		return
	if RunData.energy != 0:
		_fail("Expected successful crystallize to clear energy.")
		return
	if RunData.light_cores != 1:
		_fail("Expected 1 full light core, got %d." % RunData.light_cores)
		return
	if not is_zero_approx(RunData.light_core_progress):
		_fail("Expected light core progress 0 after full core, got %s." % RunData.light_core_progress)
		return
	if crystallization_completed_count != 1:
		_fail("Expected one crystallization_completed event, got %d." % crystallization_completed_count)
		return
	if crystallization_successes.size() != 1 or not is_equal_approx(crystallization_successes[0], 1.0):
		_fail("Expected crystallization_succeeded progress 1.0.")
		return


func _test_crystallize_full_storage_keeps_energy() -> void:
	RunData.reset_run()
	crystallization_successes.clear()
	RunData.light_cores = RunData.max_light_cores
	RunData.light_core_progress = 0.0
	RunData.add_energy(50)

	if RunData.crystallize():
		_fail("Expected crystallize to fail when light core storage is full.")
		return
	if RunData.energy != 50:
		_fail("Expected failed crystallize to keep energy 50, got %d." % RunData.energy)
		return
	if RunData.light_cores != RunData.max_light_cores:
		_fail("Expected full light core count to stay unchanged.")
		return
	if not crystallization_successes.is_empty():
		_fail("Expected failed crystallization to emit no success event.")
		return


func _test_spend_light_core() -> void:
	RunData.reset_run()
	if RunData.spend_light_core():
		_fail("Expected spend_light_core to fail without full cores.")
		return

	RunData.light_cores = 1
	RunData.light_core_progress = 0.25
	if not RunData.spend_light_core():
		_fail("Expected spend_light_core to succeed with 1 core.")
		return
	if RunData.light_cores != 0:
		_fail("Expected spend_light_core to reduce full cores to 0.")
		return
	if not is_equal_approx(RunData.light_core_progress, 0.25):
		_fail("Expected spend_light_core to preserve progress.")
		return


func _on_light_core_changed(current: float, _max_cores: float) -> void:
	light_core_events.append(current)


func _on_crystallization_succeeded(converted_progress: float) -> void:
	crystallization_successes.append(converted_progress)


func _on_crystallization_completed() -> void:
	crystallization_completed_count += 1


func _fail(message: String) -> void:
	push_error("TEST RunData light core interface failed. %s" % message)
	get_tree().quit(1)
