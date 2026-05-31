extends Node

signal parry_succeeded(is_perfect: bool)
signal player_damage_incoming(damage_context: Dictionary)
signal player_hit(damage: int)
signal player_died
signal attack_landed(damage: int)
signal attack_started
signal attack_finished
signal dodge_started
signal parry_started
signal parry_failed
signal energy_changed(current: int, max_energy: int)
signal run_reset
signal overclock_toggled(is_active: bool)
signal overclock_action_requested(action_type: StringName)
signal overclock_action_accepted(action_type: StringName, cost: int)
signal overclock_action_triggered(action_type: StringName, cost: int)
signal overclock_action_failed(action_type: StringName, reason: StringName)
signal light_core_changed(current: float, max_cores: float)
signal crystallization_succeeded(converted_progress: float)
signal crystallization_completed
signal crystallization_failed(reason: StringName)
signal altar_activated
signal altar_failed(reason: StringName)
signal talent_selection_requested
signal talent_options_generated(options: Array[Resource])
signal talent_selected(talent_data: Resource)
signal talent_applied(talent_data: Resource)
signal talent_selection_closed
signal attack_hit_target(target: Node, damage: int)
signal enemy_died(enemy: Node)
signal all_enemies_cleared
signal room_cleared
signal boss_phase_changed(phase: int)


func emit_parry_succeeded(is_perfect: bool) -> void:
	parry_succeeded.emit(is_perfect)


func emit_player_damage_incoming(damage_context: Dictionary) -> void:
	player_damage_incoming.emit(damage_context)


func emit_player_hit(damage: int) -> void:
	player_hit.emit(damage)


func emit_player_died() -> void:
	player_died.emit()


func emit_attack_landed(damage: int) -> void:
	attack_landed.emit(damage)


func emit_attack_started() -> void:
	attack_started.emit()


func emit_attack_finished() -> void:
	attack_finished.emit()


func emit_dodge_started() -> void:
	dodge_started.emit()


func emit_parry_started() -> void:
	parry_started.emit()


func emit_parry_failed() -> void:
	parry_failed.emit()


func emit_energy_changed(current: int, max_energy: int) -> void:
	energy_changed.emit(current, max_energy)


func emit_run_reset() -> void:
	run_reset.emit()


func emit_overclock_toggled(is_active: bool) -> void:
	overclock_toggled.emit(is_active)


func emit_overclock_action_requested(action_type: StringName) -> void:
	overclock_action_requested.emit(action_type)


func emit_overclock_action_accepted(action_type: StringName, cost: int) -> void:
	overclock_action_accepted.emit(action_type, cost)


func emit_overclock_action_triggered(action_type: StringName, cost: int) -> void:
	overclock_action_triggered.emit(action_type, cost)


func emit_overclock_action_failed(action_type: StringName, reason: StringName) -> void:
	overclock_action_failed.emit(action_type, reason)


func emit_light_core_changed(current: float, max_cores: float) -> void:
	light_core_changed.emit(current, max_cores)


func emit_crystallization_succeeded(converted_progress: float) -> void:
	crystallization_succeeded.emit(converted_progress)


func emit_crystallization_completed() -> void:
	crystallization_completed.emit()


func emit_crystallization_failed(reason: StringName) -> void:
	crystallization_failed.emit(reason)


func emit_altar_activated() -> void:
	altar_activated.emit()


func emit_altar_failed(reason: StringName) -> void:
	altar_failed.emit(reason)


func emit_talent_selection_requested() -> void:
	talent_selection_requested.emit()


func emit_talent_options_generated(options: Array[Resource]) -> void:
	talent_options_generated.emit(options)


func emit_talent_selected(talent_data: Resource) -> void:
	talent_selected.emit(talent_data)


func emit_talent_applied(talent_data: Resource) -> void:
	talent_applied.emit(talent_data)


func emit_talent_selection_closed() -> void:
	talent_selection_closed.emit()


func emit_attack_hit_target(target: Node, damage: int) -> void:
	attack_hit_target.emit(target, damage)


func emit_enemy_died(enemy: Node) -> void:
	enemy_died.emit(enemy)


func emit_all_enemies_cleared() -> void:
	all_enemies_cleared.emit()


func emit_room_cleared() -> void:
	room_cleared.emit()


func emit_boss_phase_changed(phase: int) -> void:
	boss_phase_changed.emit(phase)
