extends Node2D

class TestTarget:
	extends Node

	var damage_taken := 0


	func take_damage(amount: int) -> void:
		damage_taken += amount


const ALTAR_SCENE: PackedScene = preload("res://entities/interactables/altar/altar.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")
const TALENT_SELECTION_UI_SCENE: PackedScene = preload("res://ui/talent_select/talent_selection_ui.tscn")
const TALENT_SYSTEM_SCRIPT: Script = preload("res://systems/talent_system.gd")

const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

var player: Player
var altar: Node
var ui: Node
var talent_system: Node


func _ready() -> void:
	player = PLAYER_SCENE.instantiate()
	player.name = "Player"
	add_child(player)

	altar = ALTAR_SCENE.instantiate()
	altar.name = "Altar"
	add_child(altar)

	ui = TALENT_SELECTION_UI_SCENE.instantiate()
	ui.name = "TalentSelectionUI"
	add_child(ui)

	talent_system = Node.new()
	talent_system.name = "TalentSystem"
	talent_system.set_script(TALENT_SYSTEM_SCRIPT)
	talent_system.selection_ui_path = NodePath("../TalentSelectionUI")
	add_child(talent_system)

	await get_tree().process_frame

	await _test_altar_requires_light_core()
	await _test_select_crack_slash_and_burst()
	await _test_select_guard_momentum_and_reduce_damage()
	await _test_select_residual_backflow_and_refund_energy()
	_test_reset_clears_talent_runtime_state()
	await get_tree().create_timer(0.15).timeout
	await _cleanup_nodes()

	print("TEST P0-6 talent acceptance ok")
	get_tree().quit()


func _test_altar_requires_light_core() -> void:
	RunData.reset_run()
	altar.set_state(&"available")
	altar._on_body_entered(player)

	if altar.interact():
		_fail("Expected altar to fail without light cores.")
		return
	await get_tree().process_frame

	if ui.visible:
		_fail("Expected TalentSelectionUI to stay closed without light cores.")
		return
	if not RunData.acquired_talents.is_empty():
		_fail("Expected no acquired talent without light cores.")
		return


func _test_select_crack_slash_and_burst() -> void:
	RunData.reset_run()
	await _open_talent_selection_with_altar()
	_choose_card(0)
	await get_tree().process_frame

	if RunData.acquired_talents != [CRACK_SLASH]:
		_fail("Expected Crack Slash to be acquired.")
		return
	if ui.visible:
		_fail("Expected UI to close after choosing Crack Slash.")
		return

	var target := TestTarget.new()
	add_child(target)
	EventBus.emit_attack_hit_target(target, 10)
	EventBus.emit_attack_hit_target(target, 10)
	if talent_system.get_crack_stacks(target) != 2 or target.damage_taken != 0:
		_fail("Expected Crack Slash to stack twice before burst.")
		return
	EventBus.emit_attack_hit_target(target, 10)
	if talent_system.get_crack_stacks(target) != 0 or target.damage_taken != 10:
		_fail("Expected Crack Slash to burst for 10 damage and clear stacks.")
		return
	target.queue_free()
	await get_tree().process_frame


func _test_select_guard_momentum_and_reduce_damage() -> void:
	RunData.reset_run()
	await _open_talent_selection_with_altar()
	_choose_card(1)
	await get_tree().process_frame

	if RunData.acquired_talents != [GUARD_MOMENTUM]:
		_fail("Expected Guard Momentum to be acquired.")
		return

	EventBus.emit_parry_succeeded(false)
	if talent_system.get_guard_momentum_stacks() != 0:
		_fail("Expected normal parry not to grant Guard Momentum.")
		return
	EventBus.emit_parry_succeeded(true)
	if talent_system.get_guard_momentum_stacks() != 1:
		_fail("Expected perfect parry to grant Guard Momentum.")
		return

	var health_before := player.health_component.current_health
	if not player.receive_damage(8):
		_fail("Expected player to receive reduced damage.")
		return
	if player.health_component.current_health != health_before - 5:
		_fail("Expected Guard Momentum to reduce 8 damage to 5.")
		return
	if talent_system.get_guard_momentum_stacks() != 0:
		_fail("Expected Guard Momentum to be consumed after damage.")
		return


func _test_select_residual_backflow_and_refund_energy() -> void:
	RunData.reset_run()
	await _open_talent_selection_with_altar()
	_choose_card(2)
	await get_tree().process_frame

	if RunData.acquired_talents != [RESIDUAL_BACKFLOW]:
		_fail("Expected Residual Backflow to be acquired.")
		return

	RunData.add_energy(10)
	EventBus.emit_overclock_action_requested(&"attack")
	EventBus.emit_attack_landed(10)
	if RunData.energy != 8:
		_fail("Expected overclock attack to consume 3 and refund 1, got %d." % RunData.energy)
		return


func _test_reset_clears_talent_runtime_state() -> void:
	RunData.reset_run()
	if not RunData.acquired_talents.is_empty():
		_fail("Expected RunData reset to clear acquired talents.")
		return
	if not talent_system.active_options.is_empty():
		_fail("Expected run reset to clear active talent options.")
		return
	if talent_system.get_guard_momentum_stacks() != 0:
		_fail("Expected run reset to clear Guard Momentum.")
		return


func _open_talent_selection_with_altar() -> void:
	altar.set_state(&"available")
	RunData.light_cores = 1
	EventBus.emit_light_core_changed(1.0, 1.0)
	altar._on_body_entered(player)

	if not altar.interact():
		_fail("Expected altar to open talent selection with one light core.")
		return
	await get_tree().process_frame

	if not ui.visible:
		_fail("Expected TalentSelectionUI to open from altar interaction.")
		return

	var card_row: HBoxContainer = ui.get_node("Panel/CardRow")
	if card_row.get_child_count() != 3:
		_fail("Expected three talent cards.")
		return


func _choose_card(index: int) -> void:
	var card_row: HBoxContainer = ui.get_node("Panel/CardRow")
	var card: Node = card_row.get_child(index)
	var choose_button: Button = card.get_node("Content/ChooseButton")
	choose_button.pressed.emit()


func _cleanup_nodes() -> void:
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame


func _fail(message: String) -> void:
	push_error("TEST P0-6 talent acceptance failed. %s" % message)
	get_tree().quit(1)
