class_name OverclockSystem
extends Node

const REASON_NOT_ENOUGH_ENERGY := &"not_enough_energy"
const REASON_UNKNOWN_ACTION := &"unknown_action"

@export var balance: BalanceData = preload("res://data/balance/default_balance.tres")

var accepted_actions: Dictionary[StringName, int] = {}


func _ready() -> void:
	EventBus.overclock_action_requested.connect(_on_overclock_action_requested)
	EventBus.attack_landed.connect(_on_attack_landed)
	EventBus.attack_finished.connect(_on_attack_finished)
	EventBus.dodge_started.connect(_on_dodge_started)
	EventBus.parry_succeeded.connect(_on_parry_succeeded)
	EventBus.parry_failed.connect(_on_parry_failed)


func is_action_accepted(action_type: StringName) -> bool:
	return accepted_actions.has(action_type)


func get_action_cost(action_type: StringName) -> int:
	return accepted_actions.get(action_type, 0)


func clear_action(action_type: StringName) -> void:
	accepted_actions.erase(action_type)


func _on_overclock_action_requested(action_type: StringName) -> void:
	var cost := _get_cost(action_type)
	if cost <= 0:
		accepted_actions.erase(action_type)
		EventBus.emit_overclock_action_failed(action_type, REASON_UNKNOWN_ACTION)
		return

	if RunData.energy < cost:
		accepted_actions.erase(action_type)
		EventBus.emit_overclock_action_failed(action_type, REASON_NOT_ENOUGH_ENERGY)
		return

	accepted_actions[action_type] = cost
	EventBus.emit_overclock_action_accepted(action_type, cost)


func _on_attack_landed(_damage: int) -> void:
	_trigger_accepted_action(&"attack")


func _on_attack_finished() -> void:
	clear_action(&"attack")


func _on_dodge_started() -> void:
	_trigger_accepted_action(&"dodge")


func _on_parry_succeeded(_is_perfect: bool) -> void:
	call_deferred("_trigger_accepted_action", &"parry")


func _on_parry_failed() -> void:
	clear_action(&"parry")


func _trigger_accepted_action(action_type: StringName) -> void:
	if not is_action_accepted(action_type):
		return

	var cost := get_action_cost(action_type)
	clear_action(action_type)
	if RunData.consume_energy(cost):
		EventBus.emit_overclock_action_triggered(action_type, cost)
	else:
		EventBus.emit_overclock_action_failed(action_type, REASON_NOT_ENOUGH_ENERGY)


func _get_cost(action_type: StringName) -> int:
	match action_type:
		&"attack":
			return balance.overclock_attack_cost
		&"dodge":
			return balance.overclock_dodge_cost
		&"parry":
			return balance.overclock_parry_cost
		_:
			return 0
