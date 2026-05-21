extends Node


func _ready() -> void:
	RunData.reset_run()

	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	player.name = "Player"
	add_child(player)

	var hud: CanvasLayer = preload("res://ui/hud/energy_hud.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	var health_bar: ProgressBar = hud.get_node("Panel/HealthBar")
	var health_label: Label = hud.get_node("Panel/HealthLabel")
	var energy_bar: ProgressBar = hud.get_node("Panel/EnergyBar")
	var energy_label: Label = hud.get_node("Panel/EnergyLabel")

	if health_label.text != "Health 100/100":
		_fail("Expected initial label Health 100/100, got %s." % health_label.text)
		return
	if health_bar.value != 100 or health_bar.max_value != 100:
		_fail("Expected initial health bar 100/100, got %s/%s." % [health_bar.value, health_bar.max_value])
		return
	if energy_label.text != "Energy 0/100":
		_fail("Expected initial label Energy 0/100, got %s." % energy_label.text)
		return
	if energy_bar.value != 0 or energy_bar.max_value != 100:
		_fail("Expected initial bar 0/100, got %s/%s." % [energy_bar.value, energy_bar.max_value])
		return

	RunData.add_energy(12)
	await get_tree().process_frame

	if energy_label.text != "Energy 12/100":
		_fail("Expected changed label Energy 12/100, got %s." % energy_label.text)
		return
	if energy_bar.value != 12:
		_fail("Expected changed bar value 12, got %s." % energy_bar.value)
		return

	player.receive_damage(25)
	await get_tree().process_frame

	if health_label.text != "Health 75/100":
		_fail("Expected changed label Health 75/100, got %s." % health_label.text)
		return
	if health_bar.value != 75:
		_fail("Expected changed health bar value 75, got %s." % health_bar.value)
		return

	print("TEST EnergyHUD display ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST EnergyHUD failed. %s" % message)
	get_tree().quit(1)
