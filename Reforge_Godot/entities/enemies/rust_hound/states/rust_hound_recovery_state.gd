class_name RustHoundRecoveryState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	owner_node.velocity = Vector2.ZERO
	owner_node.set_attack_hitbox_enabled(false)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()

	if elapsed_time < owner_node.data.recovery_duration:
		return

	owner_node.reset_attack_cooldown()
	if owner_node.is_target_outside_disengage_range():
		state_machine.change_state(owner_node.idle_state)
	else:
		state_machine.change_state(owner_node.chase_state)
