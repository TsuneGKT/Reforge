extends Node2D

var player: Player
var elapsed_time: float = 0.0
var started_dodge := false


func _ready() -> void:
	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	player.global_position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	if not started_dodge:
		started_dodge = true
		player.get_node("StateMachine").change_state(player.dodge_state)

	if elapsed_time > player.stats.dodge_duration + 0.1:
		var distance: float = player.global_position.length()
		var current_state_name: String = player.get_node("StateMachine").current_state.name
		if distance < 70.0 or distance > 95.0:
			push_error("TEST dodge distance failed. distance=%s" % distance)
			get_tree().quit(1)
			return
		if current_state_name != "IdleState":
			push_error("TEST dodge state failed. current=%s" % current_state_name)
			get_tree().quit(1)
			return

		print("TEST dodge ok distance=%.2f state=%s" % [distance, current_state_name])
		get_tree().quit()
