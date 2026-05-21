class_name PlayerDodgeState
extends "res://components/state_machine/state.gd"

var elapsed_time: float = 0.0
var dodge_direction: Vector2 = Vector2.ZERO


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	dodge_direction = owner_node.get_movement_input()
	if dodge_direction == Vector2.ZERO:
		dodge_direction = owner_node.last_facing_direction
	else:
		dodge_direction = dodge_direction.normalized()

	owner_node.set_attack_area_enabled(false)
	owner_node.set_parry_area_enabled(false)
	owner_node.set_facing_direction(dodge_direction)
	owner_node.set_dodge_visual_enabled(true)
	owner_node.set_invincible(true)
	owner_node.request_overclock_action(&"dodge")
	EventBus.emit_dodge_started()
	print("Player dodge started")


func exit(_next_state: Node) -> void:
	owner_node.set_dodge_visual_enabled(false)
	owner_node.set_invincible(false)


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = dodge_direction * owner_node.stats.dodge_speed
	owner_node.move_and_slide()

	if elapsed_time >= owner_node.stats.dodge_invincible_duration:
		owner_node.set_invincible(false)

	if elapsed_time >= owner_node.stats.dodge_duration:
		_return_to_locomotion()


func _return_to_locomotion() -> void:
	var input_direction: Vector2 = owner_node.get_movement_input()
	if input_direction == Vector2.ZERO:
		state_machine.change_state(owner_node.idle_state)
	else:
		state_machine.change_state(owner_node.move_state)
