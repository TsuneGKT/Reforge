class_name HitStopController
extends Node

@export var feedback_system_path := NodePath("../FeedbackSystem")
@export var light_duration := 0.045
@export var strong_duration := 0.08
@export var stopped_time_scale := 0.08

var is_active := false
var active_until_msec := 0
var previous_time_scale := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bind_feedback_system()


func _process(_delta: float) -> void:
	if not is_active:
		return

	if Time.get_ticks_msec() >= active_until_msec:
		_finish_hit_stop()


func _exit_tree() -> void:
	if is_active:
		_finish_hit_stop()


func request_hit_stop(duration: float, time_scale := stopped_time_scale) -> void:
	var now := Time.get_ticks_msec()
	var requested_until := now + int(duration * 1000.0)
	active_until_msec = maxi(active_until_msec, requested_until)

	if is_active:
		Engine.time_scale = minf(Engine.time_scale, time_scale)
		return

	previous_time_scale = Engine.time_scale
	Engine.time_scale = time_scale
	is_active = true


func _finish_hit_stop() -> void:
	Engine.time_scale = previous_time_scale
	is_active = false
	active_until_msec = 0


func _bind_feedback_system() -> void:
	var feedback_system := get_node_or_null(feedback_system_path)
	if feedback_system == null:
		return
	if feedback_system.has_signal("feedback_requested"):
		feedback_system.feedback_requested.connect(_on_feedback_requested)


func _on_feedback_requested(feedback_type: StringName, _payload: Dictionary) -> void:
	match feedback_type:
		&"hit_stop_light":
			request_hit_stop(light_duration)
		&"hit_stop_strong":
			request_hit_stop(strong_duration)
