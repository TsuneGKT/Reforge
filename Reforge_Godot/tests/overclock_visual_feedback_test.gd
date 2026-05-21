extends Node


func _ready() -> void:
	var player: Player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	await get_tree().process_frame

	var default_color := Color(0.25, 0.65, 1.0, 1.0)
	var overclock_color := Color(1.0, 0.78, 0.18, 1.0)

	if not EventBus.overclock_action_triggered.is_connected(player._on_overclock_action_triggered):
		_fail("Expected player to connect overclock visual signal.")
		return

	if player.direction_marker.color != default_color:
		_fail("Expected default marker color, got %s." % player.direction_marker.color)
		return

	EventBus.emit_overclock_action_triggered(&"attack", 3)
	await get_tree().process_frame

	if player.direction_marker.color != overclock_color:
		_fail("Expected overclock marker color, got %s." % player.direction_marker.color)
		return

	await get_tree().create_timer(0.14).timeout

	if player.direction_marker.color != default_color:
		_fail("Expected marker color to restore, got %s." % player.direction_marker.color)
		return

	print("TEST overclock visual feedback ok")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("TEST overclock visual feedback failed. %s" % message)
	get_tree().quit(1)
