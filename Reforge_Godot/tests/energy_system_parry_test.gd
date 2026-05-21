extends Node

var energy_events: Array[int] = []


func _ready() -> void:
	EventBus.energy_changed.connect(_on_energy_changed)
	RunData.reset_run()

	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
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

	RunData.energy = 98
	EventBus.emit_parry_succeeded(true)
	await get_tree().process_frame
	if RunData.energy != RunData.max_energy:
		_fail("Expected energy to clamp at max, got %d." % RunData.energy)
		return

	print("TEST EnergySystem parry energy ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST EnergySystem parry failed. %s" % message)
	get_tree().quit(1)


func _on_energy_changed(current: int, _max_energy: int) -> void:
	energy_events.append(current)
