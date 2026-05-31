class_name FeedbackSystem
extends Node

signal feedback_requested(feedback_type: StringName, payload: Dictionary)

const HIT_STOP_LIGHT := &"hit_stop_light"
const HIT_STOP_STRONG := &"hit_stop_strong"
const SCREEN_SHAKE_LIGHT := &"screen_shake_light"
const FLASH_WHITE := &"flash_white"
const FLASH_RED := &"flash_red"
const OVERCLOCK_PULSE := &"overclock_pulse"
const INTERACT_CONFIRM := &"interact_confirm"
const UI_CONFIRM := &"ui_confirm"

var requested_feedback: Array[Dictionary] = []


func _ready() -> void:
	EventBus.attack_hit_target.connect(_on_attack_hit_target)
	EventBus.parry_succeeded.connect(_on_parry_succeeded)
	EventBus.player_hit.connect(_on_player_hit)
	EventBus.overclock_action_triggered.connect(_on_overclock_action_triggered)
	EventBus.crystallization_completed.connect(_on_crystallization_completed)
	EventBus.altar_activated.connect(_on_altar_activated)
	EventBus.talent_applied.connect(_on_talent_applied)


func request_feedback(feedback_type: StringName, payload := {}) -> void:
	var typed_payload: Dictionary = payload
	requested_feedback.append({
		"type": feedback_type,
		"payload": typed_payload,
	})
	feedback_requested.emit(feedback_type, typed_payload)


func get_requested_count(feedback_type: StringName) -> int:
	var count := 0
	for request in requested_feedback:
		if request.get("type") == feedback_type:
			count += 1

	return count


func clear_history() -> void:
	requested_feedback.clear()


func _on_attack_hit_target(target: Node, damage: int) -> void:
	request_feedback(HIT_STOP_LIGHT, {
		"target": target,
		"damage": damage,
	})
	request_feedback(FLASH_WHITE, {
		"target": target,
	})


func _on_parry_succeeded(is_perfect: bool) -> void:
	var hit_stop_type := HIT_STOP_STRONG if is_perfect else HIT_STOP_LIGHT
	request_feedback(hit_stop_type, {
		"is_perfect": is_perfect,
	})
	request_feedback(SCREEN_SHAKE_LIGHT, {
		"is_perfect": is_perfect,
	})
	request_feedback(FLASH_WHITE, {
		"is_perfect": is_perfect,
	})


func _on_player_hit(damage: int) -> void:
	request_feedback(FLASH_RED, {
		"damage": damage,
	})
	request_feedback(SCREEN_SHAKE_LIGHT, {
		"damage": damage,
	})


func _on_overclock_action_triggered(action_type: StringName, cost: int) -> void:
	request_feedback(OVERCLOCK_PULSE, {
		"action_type": action_type,
		"cost": cost,
	})


func _on_crystallization_completed() -> void:
	request_feedback(INTERACT_CONFIRM, {
		"source": &"crystallization",
	})


func _on_altar_activated() -> void:
	request_feedback(INTERACT_CONFIRM, {
		"source": &"altar",
	})


func _on_talent_applied(talent_data: Resource) -> void:
	request_feedback(UI_CONFIRM, {
		"talent": talent_data,
	})
