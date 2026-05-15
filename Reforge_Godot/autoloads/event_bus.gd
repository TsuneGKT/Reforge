extends Node

signal parry_succeeded(is_perfect: bool)
signal player_hit(damage: int)
signal player_died
signal attack_landed(damage: int)
signal energy_changed(current: int, max_energy: int)
signal overclock_toggled(is_active: bool)
signal light_core_changed(current: float, max_cores: float)
signal crystallization_completed
signal talent_selected(talent_data: Resource)
signal enemy_died(enemy: Node)
signal all_enemies_cleared
signal room_cleared
signal boss_phase_changed(phase: int)


func emit_parry_succeeded(is_perfect: bool) -> void:
	parry_succeeded.emit(is_perfect)


func emit_player_hit(damage: int) -> void:
	player_hit.emit(damage)


func emit_player_died() -> void:
	player_died.emit()


func emit_attack_landed(damage: int) -> void:
	attack_landed.emit(damage)


func emit_energy_changed(current: int, max_energy: int) -> void:
	energy_changed.emit(current, max_energy)


func emit_overclock_toggled(is_active: bool) -> void:
	overclock_toggled.emit(is_active)


func emit_light_core_changed(current: float, max_cores: float) -> void:
	light_core_changed.emit(current, max_cores)


func emit_crystallization_completed() -> void:
	crystallization_completed.emit()


func emit_talent_selected(talent_data: Resource) -> void:
	talent_selected.emit(talent_data)


func emit_enemy_died(enemy: Node) -> void:
	enemy_died.emit(enemy)


func emit_all_enemies_cleared() -> void:
	all_enemies_cleared.emit()


func emit_room_cleared() -> void:
	room_cleared.emit()


func emit_boss_phase_changed(phase: int) -> void:
	boss_phase_changed.emit(phase)
