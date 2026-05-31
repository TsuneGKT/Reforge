extends Node


func _ready() -> void:
	RunData.reset_run()

	var hud: CanvasLayer = preload("res://ui/hud/light_core_hud.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame

	var light_core_bar: ProgressBar = hud.get_node("Panel/LightCoreBar")
	var light_core_label: Label = hud.get_node("Panel/LightCoreLabel")

	if light_core_label.text != "Light Core 0.00/1":
		_fail("Expected initial label Light Core 0.00/1, got %s." % light_core_label.text)
		return
	if light_core_bar.value != 0.0 or light_core_bar.max_value != 1.0:
		_fail("Expected initial light core bar 0/1, got %s/%s." % [light_core_bar.value, light_core_bar.max_value])
		return

	RunData.add_energy(50)
	RunData.crystallize()
	await get_tree().process_frame

	if light_core_label.text != "Light Core 0.50/1":
		_fail("Expected changed label Light Core 0.50/1, got %s." % light_core_label.text)
		return
	if not is_equal_approx(light_core_bar.value, 0.5):
		_fail("Expected changed bar value 0.5, got %s." % light_core_bar.value)
		return

	RunData.add_energy(100)
	RunData.crystallize()
	await get_tree().process_frame

	if light_core_label.text != "Light Core 1/1 Full":
		_fail("Expected full label Light Core 1/1 Full, got %s." % light_core_label.text)
		return
	if not is_equal_approx(light_core_bar.value, 1.0):
		_fail("Expected full bar value 1.0, got %s." % light_core_bar.value)
		return

	print("TEST LightCoreHUD display ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST LightCoreHUD failed. %s" % message)
	get_tree().quit(1)
