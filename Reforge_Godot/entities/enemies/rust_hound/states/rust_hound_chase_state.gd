class_name RustHoundChaseState
extends "res://components/state_machine/state.gd"


func enter(_previous_state: Node) -> void:
	owner_node.set_attack_hitbox_enabled(false)


func physics_update(delta: float) -> void:
	owner_node.tick_attack_cooldown(delta)

	if owner_node.is_target_outside_disengage_range():
		owner_node.velocity = Vector2.ZERO
		state_machine.change_state(owner_node.idle_state)
		return

	if owner_node.can_start_attack():
		owner_node.velocity = Vector2.ZERO
		state_machine.change_state(owner_node.charge_state)
		return

	var direction: Vector2 = owner_node.get_direction_to_target()
	if direction == Vector2.ZERO:
		owner_node.velocity = Vector2.ZERO
	else:
		owner_node.set_facing_direction(direction)
		owner_node.velocity = direction * owner_node.data.move_speed

	owner_node.move_and_slide()
