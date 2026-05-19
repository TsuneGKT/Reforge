class_name State
extends Node

var state_machine: Node
var owner_node: Node


func enter(_previous_state: Node) -> void:
	pass


func exit(_next_state: Node) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
