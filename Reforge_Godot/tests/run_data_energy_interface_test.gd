extends Node

var energy_events: Array[int] = []


func _ready() -> void:
	EventBus.energy_changed.connect(_on_energy_changed)
	RunData.reset_run()

	_test_add_energy()
	_test_consume_energy()
	_test_invalid_amounts()
	get_tree().quit()


func _test_add_energy() -> void:
	if RunData.energy != 0 or RunData.max_energy != 100:
		_fail("Expected reset energy 0/100, got %d/%d." % [RunData.energy, RunData.max_energy])
		return

	if not RunData.add_energy(12):
		_fail("Expected add_energy(12) to change energy.")
		return
	if RunData.energy != 12:
		_fail("Expected energy 12, got %d." % RunData.energy)
		return

	RunData.add_energy(999)
	if RunData.energy != RunData.max_energy:
		_fail("Expected energy clamped to max, got %d." % RunData.energy)
		return
	print("TEST RunData add energy ok")


func _test_consume_energy() -> void:
	if not RunData.consume_energy(8):
		_fail("Expected consume_energy(8) to succeed.")
		return
	if RunData.energy != 92:
		_fail("Expected energy 92, got %d." % RunData.energy)
		return

	if RunData.consume_energy(999):
		_fail("Expected consume_energy(999) to fail.")
		return
	if RunData.energy != 92:
		_fail("Expected failed consume to keep 92, got %d." % RunData.energy)
		return
	print("TEST RunData consume energy ok")


func _test_invalid_amounts() -> void:
	if RunData.add_energy(0):
		_fail("Expected add_energy(0) to return false.")
		return
	if not RunData.consume_energy(0):
		_fail("Expected consume_energy(0) to return true as no-op.")
		return
	print("TEST RunData invalid amounts ok")


func _fail(message: String) -> void:
	push_error("TEST RunData energy interface failed. %s" % message)
	get_tree().quit(1)


func _on_energy_changed(current: int, _max_energy: int) -> void:
	energy_events.append(current)
