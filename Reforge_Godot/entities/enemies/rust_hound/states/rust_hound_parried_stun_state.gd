class_name RustHoundParriedStunState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	owner_node.set_attack_hitbox_enabled(false)
	owner_node.play_parried_feedback()


func exit(_next_state: Node) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node._update_body_color(owner_node.health_component.current_health, owner_node.health_component.max_health)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = owner_node.parried_knockback_direction * owner_node.data.knockback_force
	owner_node.move_and_slide()

	if elapsed_time < owner_node.data.stun_duration:
		return

	if owner_node.is_target_outside_disengage_range():
		state_machine.change_state(owner_node.idle_state)
	else:
		state_machine.change_state(owner_node.chase_state)
