extends Node

var energy: int = 0
var max_energy: int = 100
var light_core_progress: float = 0.0
var light_cores: int = 0
var max_light_cores: int = 1
var acquired_talents: Array[Resource] = []
var rooms_cleared: int = 0
var enemies_killed: int = 0
var perfect_parries: int = 0


func _ready() -> void:
	reset_run()


func reset_run() -> void:
	energy = 0
	max_energy = 100
	light_core_progress = 0.0
	light_cores = 0
	max_light_cores = 1
	acquired_talents.clear()
	rooms_cleared = 0
	enemies_killed = 0
	perfect_parries = 0
	EventBus.emit_energy_changed(energy, max_energy)
	EventBus.emit_light_core_changed(light_core_progress + float(light_cores), float(max_light_cores))
	EventBus.emit_run_reset()


func add_energy(amount: int) -> bool:
	if amount <= 0:
		return false
	var previous_energy := energy
	energy = clampi(energy + amount, 0, max_energy)
	EventBus.emit_energy_changed(energy, max_energy)
	return energy != previous_energy


func consume_energy(amount: int) -> bool:
	if amount <= 0:
		return true
	if energy < amount:
		return false
	energy -= amount
	EventBus.emit_energy_changed(energy, max_energy)
	return true


func crystallize() -> bool:
	if energy <= 0 or max_energy <= 0:
		return false
	if light_cores >= max_light_cores:
		return false

	var converted_progress := float(energy) / float(max_energy)
	energy = 0
	EventBus.emit_energy_changed(energy, max_energy)
	EventBus.emit_crystallization_succeeded(converted_progress)

	light_core_progress += converted_progress
	while light_core_progress >= 1.0 and light_cores < max_light_cores:
		light_cores += 1
		light_core_progress -= 1.0
		EventBus.emit_crystallization_completed()

	if light_cores >= max_light_cores:
		light_core_progress = 0.0

	EventBus.emit_light_core_changed(light_core_progress + float(light_cores), float(max_light_cores))
	return true


func spend_light_core() -> bool:
	if light_cores <= 0:
		return false
	light_cores -= 1
	EventBus.emit_light_core_changed(light_core_progress + float(light_cores), float(max_light_cores))
	return true


func add_talent(talent_data: Resource) -> void:
	if talent_data == null:
		return
	acquired_talents.append(talent_data)
	EventBus.emit_talent_selected(talent_data)
