class_name PlayerMoveState
extends "res://components/state_machine/state.gd"


func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("parry"):
		state_machine.change_state(owner_node.parry_state)
		return

	if Input.is_action_just_pressed("dodge"):
		state_machine.change_state(owner_node.dodge_state)
		return

	if Input.is_action_just_pressed("attack"):
		state_machine.change_state(owner_node.attack_state)
		return

	var input_direction: Vector2 = owner_node.get_movement_input()
	if input_direction == Vector2.ZERO:
		state_machine.change_state(owner_node.idle_state)
		return

	owner_node.move_in_direction(input_direction)
