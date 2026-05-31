class_name RustHoundDeadState
extends "res://components/state_machine/state.gd"


func enter(_previous_state: Node) -> void:
	owner_node.velocity = Vector2.ZERO
	owner_node.disable_combat_collisions()
	owner_node.play_death_feedback()


func physics_update(_delta: float) -> void:
	owner_node.velocity = Vector2.ZERO
