extends Node2D

const ALTAR_SCENE: PackedScene = preload("res://entities/interactables/altar/altar.tscn")
const CRYSTALLIZATION_POINT_SCENE: PackedScene = preload("res://entities/interactables/crystallization_point/crystallization_point.tscn")
const LIGHT_CORE_HUD_SCENE: PackedScene = preload("res://ui/hud/light_core_hud.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

const POINT_STATE_DISABLED := &"disabled"
const POINT_STATE_USED := &"used"
const ALTAR_STATE_USED := &"used"

var crystallization_successes: Array[float] = []
var crystallization_completed_count := 0
var crystallization_failures: Array[StringName] = []
var altar_activated_count := 0
var altar_failures: Array[StringName] = []
var talent_selection_requested_count := 0


func _ready() -> void:
	EventBus.crystallization_succeeded.connect(_on_crystallization_succeeded)
	EventBus.crystallization_completed.connect(_on_crystallization_completed)
	EventBus.crystallization_failed.connect(_on_crystallization_failed)
	EventBus.altar_activated.connect(_on_altar_activated)
	EventBus.altar_failed.connect(_on_altar_failed)
	EventBus.talent_selection_requested.connect(_on_talent_selection_requested)

	await _test_light_core_to_altar_loop()

	print("TEST P0-5 light core and altar acceptance ok")
	get_tree().quit()


func _test_light_core_to_altar_loop() -> void:
	RunData.reset_run()

	var player: Node = PLAYER_SCENE.instantiate()
	var point: Node = CRYSTALLIZATION_POINT_SCENE.instantiate()
	var altar: Node = ALTAR_SCENE.instantiate()
	var hud: CanvasLayer = LIGHT_CORE_HUD_SCENE.instantiate()
	add_child(player)
	add_child(point)
	add_child(altar)
	add_child(hud)
	await get_tree().process_frame

	var light_core_label: Label = hud.get_node("Panel/LightCoreLabel")
	var light_core_bar: ProgressBar = hud.get_node("Panel/LightCoreBar")

	if point.state != POINT_STATE_DISABLED:
		_fail("Expected crystallization point to start disabled.")
		return
	if light_core_label.text != "Light Core 0.00/1":
		_fail("Expected initial LightCoreHUD 0.00/1, got %s." % light_core_label.text)
		return

	EventBus.emit_all_enemies_cleared()
	await get_tree().process_frame

	point._on_body_entered(player)
	RunData.add_energy(100)
	if not point.interact():
		_fail("Expected crystallization point to convert 100 energy.")
		return
	await get_tree().process_frame

	if RunData.energy != 0:
		_fail("Expected crystallization to clear energy, got %d." % RunData.energy)
		return
	if RunData.light_cores != 1 or not is_equal_approx(RunData.light_core_progress, 0.0):
		_fail("Expected one full light core and zero progress.")
		return
	if point.state != POINT_STATE_USED:
		_fail("Expected crystallization point to enter Used state.")
		return
	if crystallization_successes.size() != 1 or not is_equal_approx(crystallization_successes[0], 1.0):
		_fail("Expected crystallization_succeeded progress 1.0, got %s." % [crystallization_successes])
		return
	if crystallization_completed_count != 1:
		_fail("Expected one crystallization_completed event.")
		return
	if not crystallization_failures.is_empty():
		_fail("Expected no crystallization failure in acceptance loop.")
		return
	if light_core_label.text != "Light Core 1/1 Full" or not is_equal_approx(light_core_bar.value, 1.0):
		_fail("Expected LightCoreHUD full display, got %s / %s." % [light_core_label.text, light_core_bar.value])
		return

	altar._on_body_entered(player)
	if not altar.interact():
		_fail("Expected altar to spend one light core.")
		return
	await get_tree().process_frame

	if RunData.light_cores != 0:
		_fail("Expected altar to spend the full light core.")
		return
	if altar.state != ALTAR_STATE_USED:
		_fail("Expected altar to enter Used state.")
		return
	if altar_activated_count != 1:
		_fail("Expected one altar_activated event.")
		return
	if talent_selection_requested_count != 1:
		_fail("Expected one talent_selection_requested event.")
		return
	if not altar_failures.is_empty():
		_fail("Expected no altar failure in acceptance loop.")
		return
	if light_core_label.text != "Light Core 0.00/1" or not is_equal_approx(light_core_bar.value, 0.0):
		_fail("Expected LightCoreHUD empty display after altar, got %s / %s." % [light_core_label.text, light_core_bar.value])
		return


func _on_crystallization_succeeded(converted_progress: float) -> void:
	crystallization_successes.append(converted_progress)


func _on_crystallization_completed() -> void:
	crystallization_completed_count += 1


func _on_crystallization_failed(reason: StringName) -> void:
	crystallization_failures.append(reason)


func _on_altar_activated() -> void:
	altar_activated_count += 1


func _on_altar_failed(reason: StringName) -> void:
	altar_failures.append(reason)


func _on_talent_selection_requested() -> void:
	talent_selection_requested_count += 1


func _fail(message: String) -> void:
	push_error("TEST P0-5 light core and altar acceptance failed. %s" % message)
	get_tree().quit(1)
