class_name RustHoundIdleState
extends "res://components/state_machine/state.gd"


func enter(_previous_state: Node) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node.set_attack_hitbox_enabled(false)


func physics_update(_delta: float) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()

	if owner_node.is_target_in_detection_range():
		state_machine.change_state(owner_node.chase_state)
