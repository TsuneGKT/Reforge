extends Node2D

const ALTAR_SCENE: PackedScene = preload("res://entities/interactables/altar/altar.tscn")
const PLAYER_SCENE: PackedScene = preload("res://entities/player/player.tscn")

const STATE_USED := &"used"
const STATE_BLOCKED := &"blocked"

var altar_activated_count := 0
var altar_failures: Array[StringName] = []
var talent_selection_requested_count := 0


func _ready() -> void:
	EventBus.altar_activated.connect(_on_altar_activated)
	EventBus.altar_failed.connect(_on_altar_failed)
	EventBus.talent_selection_requested.connect(_on_talent_selection_requested)

	await _test_successful_altar_interaction()
	await _test_not_enough_light_core_failure()

	print("TEST altar interaction ok")
	get_tree().quit()


func _test_successful_altar_interaction() -> void:
	RunData.reset_run()
	altar_activated_count = 0
	talent_selection_requested_count = 0
	altar_failures.clear()

	var altar: Node = ALTAR_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(altar)
	await get_tree().process_frame

	RunData.light_cores = 1
	altar._on_body_entered(player)
	if not altar.prompt_label.visible:
		_fail("Expected altar prompt to show when player enters range.")
		return
	if not altar.interact():
		_fail("Expected altar interaction to succeed with 1 light core.")
		return
	if RunData.light_cores != 0:
		_fail("Expected altar to spend 1 light core.")
		return
	if altar_activated_count != 1:
		_fail("Expected one altar_activated event.")
		return
	if talent_selection_requested_count != 1:
		_fail("Expected one talent_selection_requested event.")
		return
	if altar.state != STATE_USED:
		_fail("Expected altar to enter Used after successful interaction.")
		return

	altar.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _test_not_enough_light_core_failure() -> void:
	RunData.reset_run()
	altar_activated_count = 0
	talent_selection_requested_count = 0
	altar_failures.clear()

	var altar: Node = ALTAR_SCENE.instantiate()
	var player: Player = PLAYER_SCENE.instantiate()
	add_child(player)
	add_child(altar)
	await get_tree().process_frame

	altar._on_body_entered(player)
	if altar.interact():
		_fail("Expected altar interaction to fail without light cores.")
		return
	if altar_activated_count != 0:
		_fail("Expected no altar_activated event on failure.")
		return
	if talent_selection_requested_count != 0:
		_fail("Expected no talent_selection_requested event on failure.")
		return
	if altar_failures != [&"not_enough_light_core"]:
		_fail("Expected not_enough_light_core failure, got %s." % [altar_failures])
		return
	if altar.state != STATE_BLOCKED:
		_fail("Expected altar to enter Blocked on failure.")
		return

	altar.queue_free()
	player.queue_free()
	await get_tree().process_frame


func _on_altar_activated() -> void:
	altar_activated_count += 1


func _on_altar_failed(reason: StringName) -> void:
	altar_failures.append(reason)


func _on_talent_selection_requested() -> void:
	talent_selection_requested_count += 1


func _fail(message: String) -> void:
	push_error("TEST altar interaction failed. %s" % message)
	get_tree().quit(1)
