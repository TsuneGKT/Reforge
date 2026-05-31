class_name ScreenShakeController
extends Node

@export var feedback_system_path := NodePath("../FeedbackSystem")
@export var camera_path := NodePath("../Camera2D")
@export var light_strength := 4.0
@export var light_duration := 0.12

var camera: Camera2D
var base_offset := Vector2.ZERO
var is_active := false
var active_until_msec := 0
var current_strength := 0.0
var random := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	random.seed = 707
	camera = get_node_or_null(camera_path)
	if camera != null:
		base_offset = camera.offset
	_bind_feedback_system()


func _process(_delta: float) -> void:
	if not is_active or camera == null:
		return

	var now := Time.get_ticks_msec()
	if now >= active_until_msec:
		_finish_shake()
		return

	camera.offset = base_offset + Vector2(
		random.randf_range(-current_strength, current_strength),
		random.randf_range(-current_strength, current_strength)
	)


func _exit_tree() -> void:
	_finish_shake()


func request_shake(strength: float, duration: float) -> void:
	if camera == null:
		return

	current_strength = maxf(current_strength, strength)
	active_until_msec = max(Time.get_ticks_msec() + int(duration * 1000.0), active_until_msec)
	is_active = true


func _finish_shake() -> void:
	if camera != null:
		camera.offset = base_offset
	is_active = false
	active_until_msec = 0
	current_strength = 0.0


func _bind_feedback_system() -> void:
	var feedback_system := get_node_or_null(feedback_system_path)
	if feedback_system == null:
		return
	if feedback_system.has_signal("feedback_requested"):
		feedback_system.feedback_requested.connect(_on_feedback_requested)


func _on_feedback_requested(feedback_type: StringName, _payload: Dictionary) -> void:
	if feedback_type == &"screen_shake_light":
		request_shake(light_strength, light_duration)
