class_name TalentSystem
extends Node

const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

@export var selection_ui_path: NodePath = NodePath("../TalentSelectionUI")

var active_options: Array[Resource] = []
var crack_stacks: Dictionary[Node, int] = {}
var guard_momentum_stacks := 0


func _ready() -> void:
	EventBus.run_reset.connect(reset_runtime_state)
	EventBus.talent_selection_requested.connect(_on_talent_selection_requested)
	EventBus.attack_hit_target.connect(_on_attack_hit_target)
	EventBus.parry_succeeded.connect(_on_parry_succeeded)
	EventBus.player_damage_incoming.connect(_on_player_damage_incoming)
	EventBus.overclock_action_triggered.connect(_on_overclock_action_triggered)
	_bind_selection_ui()


func get_fixed_options() -> Array[Resource]:
	return [CRACK_SLASH, GUARD_MOMENTUM, RESIDUAL_BACKFLOW]


func choose_talent(talent_data: Resource) -> bool:
	if talent_data == null:
		return false
	if active_options.is_empty() or talent_data not in active_options:
		return false

	RunData.add_talent(talent_data)
	EventBus.emit_talent_applied(talent_data)
	EventBus.emit_talent_selection_closed()
	active_options.clear()
	return true


func has_talent(talent_id: StringName) -> bool:
	for talent in RunData.acquired_talents:
		if talent != null and talent.get("id") == talent_id:
			return true

	return false


func get_crack_stacks(target: Node) -> int:
	return crack_stacks.get(target, 0)


func get_guard_momentum_stacks() -> int:
	return guard_momentum_stacks


func reset_runtime_state() -> void:
	active_options.clear()
	crack_stacks.clear()
	guard_momentum_stacks = 0


func _on_talent_selection_requested() -> void:
	active_options = get_fixed_options()
	EventBus.emit_talent_options_generated(active_options)


func _on_attack_hit_target(target: Node, _damage: int) -> void:
	if not has_talent(CRACK_SLASH.id):
		return
	if target == null or not is_instance_valid(target):
		return
	if not target.has_method("take_damage"):
		return

	var next_stacks := get_crack_stacks(target) + 1
	if next_stacks >= int(CRACK_SLASH.effect_value):
		crack_stacks.erase(target)
		target.take_damage(int(CRACK_SLASH.effect_extra_value))
		return

	crack_stacks[target] = next_stacks


func _on_parry_succeeded(is_perfect: bool) -> void:
	if not is_perfect:
		return
	if not has_talent(GUARD_MOMENTUM.id):
		return

	guard_momentum_stacks = mini(guard_momentum_stacks + int(GUARD_MOMENTUM.effect_value), 1)


func _on_player_damage_incoming(damage_context: Dictionary) -> void:
	if guard_momentum_stacks <= 0:
		return
	if not has_talent(GUARD_MOMENTUM.id):
		return

	var amount: int = damage_context.get("amount", 0)
	amount = maxi(amount - int(GUARD_MOMENTUM.effect_extra_value), 0)
	damage_context["amount"] = amount
	guard_momentum_stacks -= 1


func _on_overclock_action_triggered(action_type: StringName, _cost: int) -> void:
	if action_type != &"attack":
		return
	if not has_talent(RESIDUAL_BACKFLOW.id):
		return

	RunData.add_energy(int(RESIDUAL_BACKFLOW.effect_value))


func _bind_selection_ui() -> void:
	var selection_ui := get_node_or_null(selection_ui_path)
	if selection_ui == null:
		return
	if selection_ui.has_signal("talent_chosen"):
		selection_ui.talent_chosen.connect(choose_talent)
