extends Node

const FEEDBACK_SYSTEM_SCRIPT: Script = preload("res://systems/feedback_system.gd")
const SCREEN_SHAKE_CONTROLLER_SCRIPT: Script = preload("res://systems/screen_shake_controller.gd")


func _ready() -> void:
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	add_child(camera)

	var feedback_system := Node.new()
	feedback_system.name = "FeedbackSystem"
	feedback_system.set_script(FEEDBACK_SYSTEM_SCRIPT)
	add_child(feedback_system)

	var screen_shake := Node.new()
	screen_shake.name = "ScreenShakeController"
	screen_shake.set_script(SCREEN_SHAKE_CONTROLLER_SCRIPT)
	screen_shake.light_duration = 0.05
	screen_shake.light_strength = 6.0
	add_child(screen_shake)
	await get_tree().process_frame

	feedback_system.request_feedback(&"screen_shake_light")
	await get_tree().process_frame

	if not screen_shake.is_active:
		_fail("Expected screen shake to become active.")
	if camera.offset == Vector2.ZERO:
		_fail("Expected Camera2D offset to move during screen shake.")

	await _wait_realtime_msec(90)

	if screen_shake.is_active:
		_fail("Expected screen shake to end after duration.")
	if camera.offset != Vector2.ZERO:
		_fail("Expected Camera2D offset to reset after screen shake.")

	print("TEST P0-7 screen shake controller ok")
	get_tree().quit()


func _wait_realtime_msec(duration_msec: int) -> void:
	var end_time := Time.get_ticks_msec() + duration_msec
	while Time.get_ticks_msec() < end_time:
		await get_tree().process_frame


func _fail(message: String) -> void:
	push_error("TEST P0-7 screen shake controller failed. %s" % message)
	get_tree().quit(1)
