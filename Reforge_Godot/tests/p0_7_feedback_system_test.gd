extends Node

const FEEDBACK_SYSTEM_SCRIPT: Script = preload("res://systems/feedback_system.gd")
const CRACK_SLASH: Resource = preload("res://data/talents/crack_slash.tres")

const HIT_STOP_LIGHT := &"hit_stop_light"
const HIT_STOP_STRONG := &"hit_stop_strong"
const SCREEN_SHAKE_LIGHT := &"screen_shake_light"
const FLASH_WHITE := &"flash_white"
const FLASH_RED := &"flash_red"
const OVERCLOCK_PULSE := &"overclock_pulse"
const INTERACT_CONFIRM := &"interact_confirm"
const UI_CONFIRM := &"ui_confirm"

var feedback_system: Node
var emitted_types: Array[StringName] = []


func _ready() -> void:
	feedback_system = Node.new()
	feedback_system.name = "FeedbackSystem"
	feedback_system.set_script(FEEDBACK_SYSTEM_SCRIPT)
	add_child(feedback_system)
	feedback_system.feedback_requested.connect(_on_feedback_requested)

	await get_tree().process_frame

	_test_attack_hit_feedback()
	_test_perfect_parry_feedback()
	_test_player_hit_feedback()
	_test_overclock_feedback()
	_test_interact_and_ui_feedback()

	print("TEST P0-7 feedback system ok")
	get_tree().quit()


func _test_attack_hit_feedback() -> void:
	var target := Node.new()
	add_child(target)
	EventBus.emit_attack_hit_target(target, 10)

	_assert_requested(HIT_STOP_LIGHT, 1)
	_assert_requested(FLASH_WHITE, 1)

	target.queue_free()


func _test_perfect_parry_feedback() -> void:
	EventBus.emit_parry_succeeded(true)

	_assert_requested(HIT_STOP_STRONG, 1)
	_assert_requested(SCREEN_SHAKE_LIGHT, 1)
	_assert_requested(FLASH_WHITE, 2)


func _test_player_hit_feedback() -> void:
	EventBus.emit_player_hit(8)

	_assert_requested(FLASH_RED, 1)
	_assert_requested(SCREEN_SHAKE_LIGHT, 2)


func _test_overclock_feedback() -> void:
	EventBus.emit_overclock_action_triggered(&"attack", 3)

	_assert_requested(OVERCLOCK_PULSE, 1)


func _test_interact_and_ui_feedback() -> void:
	EventBus.emit_crystallization_completed()
	EventBus.emit_altar_activated()
	EventBus.emit_talent_applied(CRACK_SLASH)

	_assert_requested(INTERACT_CONFIRM, 2)
	_assert_requested(UI_CONFIRM, 1)


func _on_feedback_requested(feedback_type: StringName, _payload: Dictionary) -> void:
	emitted_types.append(feedback_type)


func _assert_requested(feedback_type: StringName, expected_count: int) -> void:
	var history_count: int = feedback_system.get_requested_count(feedback_type)
	var emitted_count: int = emitted_types.count(feedback_type)
	if history_count != expected_count or emitted_count != expected_count:
		_fail("%s expected=%d history=%d emitted=%d." % [feedback_type, expected_count, history_count, emitted_count])


func _fail(message: String) -> void:
	push_error("TEST P0-7 feedback system failed. %s" % message)
	get_tree().quit(1)
