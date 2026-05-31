extends Node

const TRANSLATIONS_PATH := "res://localization/translations.csv"
const REQUIRED_KEYS := [
	"TALENT_SELECT_TITLE",
	"TALENT_SELECT_CONFIRM",
	"TALENT_SELECT_TIER_1",
	"TALENT_SELECT_ARCHETYPE_ATTACK",
	"TALENT_SELECT_ARCHETYPE_PARRY",
	"TALENT_SELECT_ARCHETYPE_OVERCLOCK",
	"TALENT_SELECT_ARCHETYPE_ENERGY",
	"TALENT_CRACK_SLASH_NAME",
	"TALENT_CRACK_SLASH_DESC",
	"TALENT_GUARD_MOMENTUM_NAME",
	"TALENT_GUARD_MOMENTUM_DESC",
	"TALENT_RESIDUAL_BACKFLOW_NAME",
	"TALENT_RESIDUAL_BACKFLOW_DESC",
	"KEYWORD_RESONANCE_NAME",
	"KEYWORD_BACKFLOW_NAME",
	"KEYWORD_CRACK_NAME",
	"KEYWORD_OVERLOAD_NAME",
	"KEYWORD_GUARD_MOMENTUM_NAME",
	"KEYWORD_RESONANCE_TOOLTIP",
	"KEYWORD_BACKFLOW_TOOLTIP",
	"KEYWORD_CRACK_TOOLTIP",
	"KEYWORD_OVERLOAD_TOOLTIP",
	"KEYWORD_GUARD_MOMENTUM_TOOLTIP",
]


func _ready() -> void:
	var file := FileAccess.open(TRANSLATIONS_PATH, FileAccess.READ)
	if file == null:
		_fail("Could not open %s." % TRANSLATIONS_PATH)
		return

	var found := {}
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty() or row[0].is_empty():
			continue

		found[row[0]] = row

	for key in REQUIRED_KEYS:
		if not found.has(key):
			_fail("Missing localization key %s." % key)
			return

		var row: PackedStringArray = found[key]
		if row.size() != 4:
			_fail("Expected %s to keep keys,ja,zh,en columns, got %d." % [key, row.size()])
			return

	print("TEST P0-6 localization keys ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST P0-6 localization keys failed. %s" % message)
	get_tree().quit(1)
