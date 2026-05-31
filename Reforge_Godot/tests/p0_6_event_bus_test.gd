extends Node

const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

var generated_options: Array[Resource] = []
var applied_talents: Array[Resource] = []
var selection_closed_count := 0
var hit_targets: Array[Node] = []
var hit_damages: Array[int] = []
var incoming_damage_contexts: Array[Dictionary] = []


func _ready() -> void:
	EventBus.talent_options_generated.connect(_on_talent_options_generated)
	EventBus.talent_applied.connect(_on_talent_applied)
	EventBus.talent_selection_closed.connect(_on_talent_selection_closed)
	EventBus.attack_hit_target.connect(_on_attack_hit_target)
	EventBus.player_damage_incoming.connect(_on_player_damage_incoming)

	var options: Array[Resource] = [CRACK_SLASH, GUARD_MOMENTUM, RESIDUAL_BACKFLOW]
	EventBus.emit_talent_options_generated(options)
	EventBus.emit_talent_applied(GUARD_MOMENTUM)
	EventBus.emit_talent_selection_closed()

	var target := Node.new()
	add_child(target)
	EventBus.emit_attack_hit_target(target, 10)
	var damage_context := {"amount": 8}
	EventBus.emit_player_damage_incoming(damage_context)
	await get_tree().process_frame

	if generated_options != options:
		_fail("Expected generated options to pass through EventBus.")
		return
	if applied_talents != [GUARD_MOMENTUM]:
		_fail("Expected applied talent to pass through EventBus.")
		return
	if selection_closed_count != 1:
		_fail("Expected one talent_selection_closed event.")
		return
	if hit_targets != [target] or hit_damages != [10]:
		_fail("Expected attack_hit_target to include target and damage.")
		return
	if incoming_damage_contexts != [damage_context]:
		_fail("Expected player_damage_incoming to pass damage context.")
		return

	print("TEST P0-6 EventBus talent signals ok")
	get_tree().quit()


func _on_talent_options_generated(options: Array[Resource]) -> void:
	generated_options = options


func _on_talent_applied(talent_data: Resource) -> void:
	applied_talents.append(talent_data)


func _on_talent_selection_closed() -> void:
	selection_closed_count += 1


func _on_attack_hit_target(target: Node, damage: int) -> void:
	hit_targets.append(target)
	hit_damages.append(damage)


func _on_player_damage_incoming(damage_context: Dictionary) -> void:
	incoming_damage_contexts.append(damage_context)


func _fail(message: String) -> void:
	push_error("TEST P0-6 EventBus talent signals failed. %s" % message)
	get_tree().quit(1)
