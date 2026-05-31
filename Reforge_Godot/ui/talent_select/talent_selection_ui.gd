class_name TalentSelectionUI
extends CanvasLayer

signal talent_chosen(talent_data: Resource)

const KEYWORD_TOOLTIP_KEYS := {
	&"resonance": &"KEYWORD_RESONANCE_TOOLTIP",
	&"backflow": &"KEYWORD_BACKFLOW_TOOLTIP",
	&"crack": &"KEYWORD_CRACK_TOOLTIP",
	&"overload": &"KEYWORD_OVERLOAD_TOOLTIP",
	&"guard_momentum": &"KEYWORD_GUARD_MOMENTUM_TOOLTIP",
}

const KEYWORD_NAME_KEYS := {
	&"resonance": &"KEYWORD_RESONANCE_NAME",
	&"backflow": &"KEYWORD_BACKFLOW_NAME",
	&"crack": &"KEYWORD_CRACK_NAME",
	&"overload": &"KEYWORD_OVERLOAD_NAME",
	&"guard_momentum": &"KEYWORD_GUARD_MOMENTUM_NAME",
}

const ARCHETYPE_KEYS := {
	&"attack": &"TALENT_SELECT_ARCHETYPE_ATTACK",
	&"parry": &"TALENT_SELECT_ARCHETYPE_PARRY",
	&"overclock": &"TALENT_SELECT_ARCHETYPE_OVERCLOCK",
	&"energy": &"TALENT_SELECT_ARCHETYPE_ENERGY",
}

@onready var title_label: Label = $Panel/TitleLabel
@onready var card_row: HBoxContainer = $Panel/CardRow
@onready var tooltip_panel: Panel = $Panel/TooltipPanel
@onready var tooltip_label: Label = $Panel/TooltipPanel/TooltipLabel

var current_options: Array[Resource] = []


func _ready() -> void:
	visible = false
	EventBus.talent_options_generated.connect(open)
	EventBus.talent_selection_closed.connect(close)
	title_label.text = tr("TALENT_SELECT_TITLE")
	tooltip_panel.visible = false


func open(options: Array[Resource]) -> void:
	current_options = options
	_rebuild_cards()
	tooltip_panel.visible = false
	visible = true


func close() -> void:
	visible = false
	tooltip_panel.visible = false


func show_tooltips_for_card(talent_data: Resource) -> void:
	var lines: Array[String] = []
	for keyword in talent_data.keywords:
		var tooltip_key: StringName = KEYWORD_TOOLTIP_KEYS.get(keyword, &"")
		if tooltip_key != &"":
			lines.append(tr(String(tooltip_key)))

	tooltip_label.text = "\n".join(lines)
	tooltip_panel.visible = not lines.is_empty()


func hide_tooltips() -> void:
	tooltip_panel.visible = false


func _rebuild_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()

	for option in current_options:
		card_row.add_child(_create_card(option))


func _create_card(talent_data: Resource) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(250.0, 260.0)
	card.mouse_entered.connect(show_tooltips_for_card.bind(talent_data))
	card.mouse_exited.connect(hide_tooltips)

	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	card.add_child(content)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = tr(String(talent_data.name_key))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(name_label)

	var tier_label := Label.new()
	tier_label.name = "TierLabel"
	tier_label.text = tr("TALENT_SELECT_TIER_%d" % talent_data.tier)
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(tier_label)

	var archetype_label := Label.new()
	archetype_label.name = "ArchetypeLabel"
	archetype_label.text = _get_archetype_text(talent_data)
	archetype_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(archetype_label)

	var keyword_label := Label.new()
	keyword_label.name = "KeywordLabel"
	keyword_label.text = _get_keyword_text(talent_data)
	keyword_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keyword_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.25))
	content.add_child(keyword_label)

	var description_label := Label.new()
	description_label.name = "DescriptionLabel"
	description_label.text = tr(String(talent_data.description_key))
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(description_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var choose_button := Button.new()
	choose_button.name = "ChooseButton"
	choose_button.text = tr("TALENT_SELECT_CONFIRM")
	choose_button.pressed.connect(_choose.bind(talent_data))
	content.add_child(choose_button)

	return card


func _choose(talent_data: Resource) -> void:
	talent_chosen.emit(talent_data)


func _get_archetype_text(talent_data: Resource) -> String:
	var parts: Array[String] = []
	_add_archetype_text(parts, talent_data.primary_archetype)
	_add_archetype_text(parts, talent_data.secondary_archetype)
	return " / ".join(parts)


func _add_archetype_text(parts: Array[String], archetype: StringName) -> void:
	if archetype == &"":
		return

	var key: StringName = ARCHETYPE_KEYS.get(archetype, &"")
	parts.append(tr(String(key)) if key != &"" else String(archetype))


func _get_keyword_text(talent_data: Resource) -> String:
	var parts: Array[String] = []
	for keyword in talent_data.keywords:
		var key: StringName = KEYWORD_NAME_KEYS.get(keyword, &"")
		parts.append(tr(String(key)) if key != &"" else String(keyword))
	return " / ".join(parts)
