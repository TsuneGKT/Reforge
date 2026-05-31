extends Node

const TRANSLATIONS_PATH := "res://localization/translations.csv"
const REQUIRED_KEYS := [
	"UI_NOT_ENOUGH_ENERGY",
	"UI_LIGHT_CORE_FULL",
	"UI_NEED_LIGHT_CORE",
	"UI_TALENT_REQUESTED_PLACEHOLDER",
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
			_fail("Expected %s to keep keys,ja,zh,en columns." % key)
			return

	print("TEST p0_5 localization keys ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST p0_5 localization keys failed. %s" % message)
	get_tree().quit(1)
