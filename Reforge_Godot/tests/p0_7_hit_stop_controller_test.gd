extends Node

const FEEDBACK_SYSTEM_SCRIPT: Script = preload("res://systems/feedback_system.gd")
const HIT_STOP_CONTROLLER_SCRIPT: Script = preload("res://systems/hit_stop_controller.gd")


func _ready() -> void:
	var feedback_system := Node.new()
	feedback_system.name = "FeedbackSystem"
	feedback_system.set_script(FEEDBACK_SYSTEM_SCRIPT)
	add_child(feedback_system)

	var hit_stop := Node.new()
	hit_stop.name = "HitStopController"
	hit_stop.set_script(HIT_STOP_CONTROLLER_SCRIPT)
	hit_stop.light_duration = 0.04
	hit_stop.strong_duration = 0.07
	add_child(hit_stop)
	await get_tree().process_frame

	var original_time_scale := Engine.time_scale
	feedback_system.request_feedback(&"hit_stop_light")
	await get_tree().process_frame

	if not hit_stop.is_active:
		_fail("Expected hit stop to become active.")
	if not Engine.time_scale < original_time_scale:
		_fail("Expected Engine.time_scale to be reduced during hit stop.")

	await _wait_realtime_msec(90)

	if hit_stop.is_active:
		_fail("Expected hit stop to end after real-time duration.")
	if not is_equal_approx(Engine.time_scale, original_time_scale):
		_fail("Expected Engine.time_scale to be restored.")

	print("TEST P0-7 hit stop controller ok")
	get_tree().quit()


func _wait_realtime_msec(duration_msec: int) -> void:
	var end_time := Time.get_ticks_msec() + duration_msec
	while Time.get_ticks_msec() < end_time:
		await get_tree().process_frame


func _fail(message: String) -> void:
	Engine.time_scale = 1.0
	push_error("TEST P0-7 hit stop controller failed. %s" % message)
	get_tree().quit(1)
