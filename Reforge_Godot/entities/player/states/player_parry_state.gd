class_name PlayerParryState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	owner_node.velocity = Vector2.ZERO
	owner_node.set_attack_area_enabled(false)
	owner_node.set_parry_area_enabled(true)
	owner_node.request_overclock_action(&"parry")
	EventBus.emit_parry_started()
	print("Player parry window opened")


func exit(_next_state: Node) -> void:
	owner_node.set_parry_area_enabled(false)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()

	var is_perfect: bool = elapsed_time <= owner_node.stats.perfect_parry_duration
	if owner_node.resolve_parry_overlaps(is_perfect):
		_return_to_locomotion()
		return

	if elapsed_time >= owner_node.stats.parry_window_duration:
		EventBus.emit_parry_failed()
		_return_to_locomotion()


func _return_to_locomotion() -> void:
	var input_direction: Vector2 = owner_node.get_movement_input()
	if input_direction == Vector2.ZERO:
		state_machine.change_state(owner_node.idle_state)
	else:
		state_machine.change_state(owner_node.move_state)
