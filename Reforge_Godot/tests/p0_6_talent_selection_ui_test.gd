extends Node

const TALENT_SELECTION_UI_SCENE: PackedScene = preload("res://ui/talent_select/talent_selection_ui.tscn")
const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")
const GUARD_MOMENTUM: Resource = preload("res://data/talents/guard_momentum.tres")
const RESIDUAL_BACKFLOW: Resource = preload("res://data/talents/residual_backflow.tres")

var chosen_talents: Array[Resource] = []


func _ready() -> void:
	var ui: Node = TALENT_SELECTION_UI_SCENE.instantiate()
	add_child(ui)
	ui.talent_chosen.connect(_on_talent_chosen)
	await get_tree().process_frame

	var options: Array[Resource] = [CRACK_SLASH, GUARD_MOMENTUM, RESIDUAL_BACKFLOW]
	EventBus.emit_talent_options_generated(options)
	await get_tree().process_frame

	if not ui.visible:
		_fail("Expected UI to become visible after talent options are generated.")
		return

	var card_row: HBoxContainer = ui.get_node("Panel/CardRow")
	if card_row.get_child_count() != 3:
		_fail("Expected 3 talent cards, got %d." % card_row.get_child_count())
		return

	var first_card: Node = card_row.get_child(0)
	var first_name: Label = first_card.get_node("Content/NameLabel")
	var first_keyword: Label = first_card.get_node("Content/KeywordLabel")
	if first_name.text.is_empty():
		_fail("Expected first card to show a talent name.")
		return
	if first_keyword.text == "crack" or first_keyword.text.is_empty():
		_fail("Expected Crack Slash keyword to show localized text, got %s." % first_keyword.text)
		return

	ui.show_tooltips_for_card(CRACK_SLASH)
	var tooltip_panel: Panel = ui.get_node("Panel/TooltipPanel")
	var tooltip_label: Label = ui.get_node("Panel/TooltipPanel/TooltipLabel")
	if not tooltip_panel.visible or tooltip_label.text.is_empty():
		_fail("Expected tooltip to show for hovered card.")
		return

	var second_card: Node = card_row.get_child(1)
	var choose_button: Button = second_card.get_node("Content/ChooseButton")
	choose_button.pressed.emit()
	await get_tree().process_frame

	if chosen_talents != [GUARD_MOMENTUM]:
		_fail("Expected choosing second card to emit Guard Momentum.")
		return

	print("TEST P0-6 TalentSelectionUI display ok")
	get_tree().quit()


func _on_talent_chosen(talent_data: Resource) -> void:
	chosen_talents.append(talent_data)


func _fail(message: String) -> void:
	push_error("TEST P0-6 TalentSelectionUI display failed. %s" % message)
	get_tree().quit(1)
