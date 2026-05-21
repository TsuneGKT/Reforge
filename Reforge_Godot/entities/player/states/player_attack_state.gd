class_name PlayerAttackState
extends "res://components/state_machine/state.gd"

const STARTUP_DURATION := 0.08
const ACTIVE_DURATION := 0.10

var elapsed_time: float = 0.0
var active_started := false


func enter(_previous_state: Node) -> void:
	elapsed_time = 0.0
	active_started = false
	owner_node.velocity = Vector2.ZERO
	owner_node.set_attack_area_enabled(false)
	owner_node.request_overclock_action(&"attack")
	EventBus.emit_attack_started()


func exit(_next_state: Node) -> void:
	owner_node.set_attack_area_enabled(false)
	EventBus.emit_attack_finished()


func physics_update(delta: float) -> void:
	elapsed_time += delta
	owner_node.velocity = Vector2.ZERO
	owner_node.move_and_slide()

	if not active_started and elapsed_time >= STARTUP_DURATION:
		active_started = true
		owner_node.set_attack_area_enabled(true)
		owner_node.resolve_attack_overlaps()

	if active_started and elapsed_time >= STARTUP_DURATION + ACTIVE_DURATION:
		owner_node.set_attack_area_enabled(false)
	elif active_started:
		owner_node.resolve_attack_overlaps()

	if elapsed_time >= owner_node.stats.attack_lock_duration:
		var input_direction: Vector2 = owner_node.get_movement_input()
		if input_direction == Vector2.ZERO:
			state_machine.change_state(owner_node.idle_state)
		else:
			state_machine.change_state(owner_node.move_state)
