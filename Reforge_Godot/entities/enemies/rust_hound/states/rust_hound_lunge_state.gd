class_name RustHoundLungeState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	owner_node.set_attack_hitbox_enabled(true)


func exit(_next_state: Node) -> void:
	owner_node.set_attack_hitbox_enabled(false)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	var lunge_speed: float = owner_node.data.lunge_distance / owner_node.data.lunge_duration
	owner_node.velocity = owner_node.locked_attack_direction * lunge_speed
	owner_node.move_and_slide()
	owner_node.resolve_attack_overlaps()

	if elapsed_time >= owner_node.data.lunge_duration:
		state_machine.change_state(owner_node.recovery_state)
