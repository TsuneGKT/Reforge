extends Node2D

var player: Player
var elapsed_time: float = 0.0
var started_dodge := false
var checked_invincible_window := false


func _ready() -> void:
	player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	if not started_dodge:
		started_dodge = true
		player.get_node("StateMachine").change_state(player.dodge_state)

	if not checked_invincible_window and elapsed_time >= player.stats.dodge_invincible_duration * 0.5:
		checked_invincible_window = true
		if player.can_receive_damage():
			push_error("TEST dodge invincibility failed. Player can receive damage during invincible window.")
			get_tree().quit(1)
			return
		print("TEST dodge invincible window active")

	if elapsed_time > player.stats.dodge_invincible_duration + 0.08:
		if not player.can_receive_damage():
			push_error("TEST dodge invincibility failed. Player is still invincible after window.")
			get_tree().quit(1)
			return
		print("TEST dodge invincible window ended")
		get_tree().quit()
