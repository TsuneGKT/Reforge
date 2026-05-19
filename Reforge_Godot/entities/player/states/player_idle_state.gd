class_name PlayerIdleState
extends "res://components/state_machine/state.gd"


func enter(_previous_state: Node) -> void:
	owner_node.velocity = Vector2.ZERO


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
	if input_direction != Vector2.ZERO:
		state_machine.change_state(owner_node.move_state)
		return

	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()
