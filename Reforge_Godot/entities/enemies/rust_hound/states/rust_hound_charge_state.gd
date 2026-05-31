class_name RustHoundChargeState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	owner_node.velocity = Vector2.ZERO
	owner_node.lock_attack_direction(owner_node.get_direction_to_target())
	owner_node.set_attack_hitbox_enabled(false)
	owner_node.body_sprite.color = Color(0.95, 0.45, 0.16, 1.0)


func exit(_next_state: Node) -> void:
	owner_node._update_body_color(owner_node.health_component.current_health, owner_node.health_component.max_health)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()

	if elapsed_time >= owner_node.data.charge_duration:
		state_machine.change_state(owner_node.lunge_state)
