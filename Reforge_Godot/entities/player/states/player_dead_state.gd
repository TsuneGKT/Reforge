class_name PlayerDeadState
extends "res://components/state_machine/state.gd"


func enter(_previous_state: Node) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node.set_attack_area_enabled(false)
	owner_node.set_parry_area_enabled(false)
	owner_node.set_dodge_visual_enabled(false)
	owner_node.set_invincible(false)
	owner_node.direction_marker.color = Color(0.8, 0.15, 0.15, 1.0)
	print("Player dead state entered")


func physics_update(_delta: float) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()
