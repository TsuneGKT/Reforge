extends Node

const TALENT_SYSTEM_SCRIPT: Script = preload("res://systems/talent_system.gd")
const TALENT_SELECTION_UI_SCENE: PackedScene = preload("res://ui/talent_select/talent_selection_ui.tscn")
const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

var generated_options: Array[Resource] = []
var selected_talents: Array[Resource] = []
var applied_talents: Array[Resource] = []
var selection_closed_count := 0


func _ready() -> void:
	RunData.reset_run()
	EventBus.talent_options_generated.connect(_on_talent_options_generated)
	EventBus.talent_selected.connect(_on_talent_selected)
	EventBus.talent_applied.connect(_on_talent_applied)
	EventBus.talent_selection_closed.connect(_on_talent_selection_closed)

	var ui: Node = TALENT_SELECTION_UI_SCENE.instantiate()
	ui.name = "TalentSelectionUI"
	add_child(ui)

	var system := Node.new()
	system.name = "TalentSystem"
	system.set_script(TALENT_SYSTEM_SCRIPT)
	system.selection_ui_path = NodePath("../TalentSelectionUI")
	add_child(system)
	await get_tree().process_frame

	EventBus.emit_talent_selection_requested()
	await get_tree().process_frame

	var expected_options: Array[Resource] = [CRACK_SLASH, GUARD_MOMENTUM, RESIDUAL_BACKFLOW]
	if generated_options != expected_options:
		_fail("Expected fixed P0-6 talent options.")
		return
	if system.active_options != expected_options:
		_fail("Expected TalentSystem to keep active options.")
		return
	if not ui.visible:
		_fail("Expected TalentSelectionUI to open after options are generated.")
		return

	if not system.choose_talent(GUARD_MOMENTUM):
		_fail("Expected TalentSystem to accept active option.")
		return
	await get_tree().process_frame

	if RunData.acquired_talents != [GUARD_MOMENTUM]:
		_fail("Expected RunData to record chosen talent.")
		return
	if selected_talents != [GUARD_MOMENTUM]:
		_fail("Expected talent_selected event after RunData.add_talent.")
		return
	if applied_talents != [GUARD_MOMENTUM]:
		_fail("Expected talent_applied event after choosing talent.")
		return
	if selection_closed_count != 1:
		_fail("Expected talent_selection_closed after choosing talent.")
		return
	if ui.visible:
		_fail("Expected TalentSelectionUI to close after choosing talent.")
		return
	if not system.active_options.is_empty():
		_fail("Expected TalentSystem to clear active options.")
		return

	print("TEST P0-6 TalentSystem minimal flow ok")
	get_tree().quit()


func _on_talent_options_generated(options: Array[Resource]) -> void:
	generated_options = options


func _on_talent_selected(talent_data: Resource) -> void:
	selected_talents.append(talent_data)


func _on_talent_applied(talent_data: Resource) -> void:
	applied_talents.append(talent_data)


func _on_talent_selection_closed() -> void:
	selection_closed_count += 1


func _fail(message: String) -> void:
	push_error("TEST P0-6 TalentSystem minimal flow failed. %s" % message)
	get_tree().quit(1)
