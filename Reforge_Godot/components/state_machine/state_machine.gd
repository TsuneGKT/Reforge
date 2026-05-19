class_name StateMachine
extends Node

@export var initial_state: Node

var current_state: Node
var owner_node: Node


func _ready() -> void:
	owner_node = get_parent()
	for child in get_children():
		if child.has_method("enter"):
			child.state_machine = self
			child.owner_node = owner_node

	if initial_state == null:
		for child in get_children():
			if child.has_method("enter"):
				initial_state = child
				break

	change_state(initial_state)


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


func change_state(next_state: Node) -> void:
	if next_state == null or next_state == current_state:
		return

	var previous_state: Node = current_state
	if current_state != null:
		current_state.exit(next_state)

	current_state = next_state
	current_state.enter(previous_state)
