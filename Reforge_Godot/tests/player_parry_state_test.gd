extends Node2D

var player: Player
var elapsed_time: float = 0.0
var pressed_parry := false


func _ready() -> void:
	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	if not pressed_parry:
		pressed_parry = true
		Input.action_press("parry")
	elif elapsed_time > 0.02:
		Input.action_release("parry")

	if elapsed_time > player.stats.parry_window_duration + 0.1:
		var current_state_name: String = player.get_node("StateMachine").current_state.name
		print("TEST parry state ended in=%s preview_visible=%s" % [current_state_name, player.parry_preview.visible])
		get_tree().quit()
